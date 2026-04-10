<template>
  <div>
    <h2 class="tw-text-lg tw-font-bold">Traffic Over Time</h2>
    <ul class="nav nav-tabs tw-mb-4" role="tablist">
      <li
        v-for="tab in tabs"
        :key="tab.key"
        role="presentation"
        :class="{ active: activeTab === tab.key }"
      >
        <a
          href="#"
          role="tab"
          :aria-selected="activeTab === tab.key"
          @click.prevent="activeTab = tab.key"
        >
          {{ tab.label }}
        </a>
      </li>
    </ul>

    <div v-if="loading" class="tw-text-center tw-py-8 tw-text-neutral-500">
      Loading stats...
    </div>

    <div v-else-if="error" class="tw-text-center tw-py-8 tw-text-red-600">
      {{ error }}
    </div>

    <template v-else-if="stats">
      <div class="tw-mb-6" style="height: 255px">
        <Bar :data="chartData" :options="chartOptions" />
      </div>

      <!-- Accessible data table -->
      <details class="tw-mb-6">
        <summary class="tw-text-sm tw-text-neutral-500 tw-cursor-pointer">
          View as table
        </summary>
        <table class="table table-hover tw-mt-2">
          <thead>
            <tr>
              <th scope="col">
                {{ activeTabConfig.axisLabel }} ({{ browserTimezoneShort }})
              </th>
              <th scope="col">Clicks</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, i) in tableRows" :key="i">
              <td>
                <time :datetime="row.iso">{{ row.label }}</time>
              </td>
              <td>{{ row.count }}</td>
            </tr>
          </tbody>
        </table>
      </details>

      <!-- Summary stats -->
      <h2 class="tw-text-lg tw-font-bold tw-mb-2">Summary</h2>
      <table class="table table-hover">
        <thead>
          <tr>
            <th scope="col">Time Period</th>
            <th scope="col">Total Hits</th>
            <th scope="col">Average</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Last 24 Hours</td>
            <td>{{ pluralize(sumClicks("hrs24"), "hit") }}</td>
            <td>{{ avgClicks("hrs24", 24).toFixed(2) }} per hour</td>
          </tr>
          <tr>
            <td>Last 7 Days</td>
            <td>{{ pluralize(sumClicks("days7"), "hit") }}</td>
            <td>{{ avgClicks("days7", 7).toFixed(2) }} per day</td>
          </tr>
          <tr>
            <td>Last 30 Days</td>
            <td>{{ pluralize(sumClicks("days30"), "hit") }}</td>
            <td>{{ avgClicks("days30", 30).toFixed(2) }} per day</td>
          </tr>
          <tr>
            <td>All Time</td>
            <td>{{ pluralize(stats.url.total_clicks, "hit") }}</td>
            <td>{{ alltimeAvg.toFixed(2) }} per day</td>
          </tr>
        </tbody>
      </table>

      <div v-if="stats.best_day" class="panel panel-default">
        <h2 class="panel-heading tw-mb-0 tw-text-base tw-text-left">
          Best Day
        </h2>
        <div class="panel-body">
          {{ formatBestDay(stats.best_day) }}
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { Bar } from "vue-chartjs";
import {
  Chart as ChartJS,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
} from "chart.js";
import { getUrlStats } from "@/api";
import type { UrlStatsResponse, ClickGranularity } from "@/types";

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip);

const props = defineProps<{
  keyword: string;
}>();

const tabs = [
  { key: "hrs24", label: "Last 24 Hours", axisLabel: "Time", granularity: "hour" },
  { key: "days7", label: "Last 7 Days", axisLabel: "Date", granularity: "day" },
  { key: "days30", label: "Last 30 Days", axisLabel: "Date", granularity: "day" },
  { key: "year", label: "Last Year", axisLabel: "Month", granularity: "month" },
  { key: "years5", label: "Last 5 Years", axisLabel: "Month", granularity: "month" },
] as const satisfies readonly {
  key: string;
  label: string;
  axisLabel: string;
  granularity: ClickGranularity;
}[];

type TabKey = (typeof tabs)[number]["key"];

const activeTab = ref<TabKey>("hrs24");
const stats = ref<UrlStatsResponse | null>(null);
const loading = ref(true);
const error = ref<string | null>(null);

// IANA timezone name, e.g. "America/Chicago"
const browserTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;

// Short abbreviation, e.g. "CDT" — extracted from a formatted date
const browserTimezoneShort = (() => {
  const parts = new Intl.DateTimeFormat(undefined, {
    timeZoneName: "short",
  }).formatToParts(new Date());
  return parts.find((p) => p.type === "timeZoneName")?.value ?? browserTimezone;
})();

const activeTabConfig = computed(
  () => tabs.find((t) => t.key === activeTab.value)!,
);

onMounted(async () => {
  try {
    stats.value = await getUrlStats(props.keyword);
  } catch (e) {
    console.error("Failed to fetch url stats", e);
    error.value = "Failed to load stats.";
  } finally {
    loading.value = false;
  }
});

function formatBucket(date: Date, granularity: ClickGranularity): string {
  switch (granularity) {
    case "hour":
      return date.toLocaleTimeString(undefined, {
        hour: "numeric",
        minute: "2-digit",
      });
    case "day":
      return date.toLocaleDateString(undefined, {
        month: "numeric",
        day: "numeric",
      });
    case "month":
      return date.toLocaleDateString(undefined, {
        month: "short",
        year: "numeric",
      });
  }
}

// Truncate a date to the start of its containing bucket, in local time.
// The server returns hourly UTC buckets; the client aggregates them into
// whatever the chart's display granularity is, honoring the viewer's
// timezone so day/month boundaries align with local wall-clock time.
function bucketStart(date: Date, granularity: ClickGranularity): Date {
  switch (granularity) {
    case "hour":
      return new Date(
        date.getFullYear(),
        date.getMonth(),
        date.getDate(),
        date.getHours(),
      );
    case "day":
      return new Date(date.getFullYear(), date.getMonth(), date.getDate());
    case "month":
      return new Date(date.getFullYear(), date.getMonth(), 1);
  }
}

const activeSeries = computed(() => {
  if (!stats.value) return null;
  return stats.value.clicks[activeTab.value];
});

interface TableRow {
  iso: string;
  label: string;
  count: number;
}

const tableRows = computed<TableRow[]>(() => {
  const series = activeSeries.value;
  if (!series) return [];

  const granularity = activeTabConfig.value.granularity;

  // Aggregate hourly server buckets into local-time display buckets. Key by
  // the millisecond timestamp of the local bucket start — unique, sortable,
  // and collision-free for different local buckets.
  const buckets = new Map<number, { start: Date; count: number }>();

  for (const [iso, count] of Object.entries(series)) {
    const start = bucketStart(new Date(iso), granularity);
    const key = start.getTime();
    const existing = buckets.get(key);
    if (existing) {
      existing.count += count;
    } else {
      buckets.set(key, { start, count });
    }
  }

  return Array.from(buckets.values())
    .sort((a, b) => a.start.getTime() - b.start.getTime())
    .map(({ start, count }) => ({
      iso: start.toISOString(),
      label: formatBucket(start, granularity),
      count,
    }));
});

const chartData = computed(() => ({
  labels: tableRows.value.map((r) => r.label),
  datasets: [
    {
      label: "Clicks",
      data: tableRows.value.map((r) => r.count),
      backgroundColor: "#FFCC32",
    },
  ],
}));

const chartOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
  },
  scales: {
    x: {
      title: {
        display: true,
        text: `${activeTabConfig.value.axisLabel} (${browserTimezoneShort})`,
      },
    },
    y: { title: { display: true, text: "Clicks" }, beginAtZero: true },
  },
}));

function sumClicks(key: TabKey): number {
  if (!stats.value) return 0;
  return Object.values(stats.value.clicks[key]).reduce((sum, n) => sum + n, 0);
}

function avgClicks(key: TabKey, divisor: number): number {
  return sumClicks(key) / divisor;
}

const alltimeAvg = computed(() => {
  if (!stats.value) return 0;
  const createdAt = new Date(stats.value.url.created_at);
  const days = Math.max(
    1,
    Math.ceil((Date.now() - createdAt.getTime()) / (1000 * 60 * 60 * 24)),
  );
  return stats.value.url.total_clicks / days;
});

function pluralize(count: number, singular: string): string {
  return `${count} ${count === 1 ? singular : singular + "s"}`;
}

function formatBestDay(bestDay: { date: string; count: number }): string {
  const date = new Date(bestDay.date + "T00:00:00");
  const formatted = date.toLocaleDateString(undefined, {
    month: "long",
    day: "numeric",
    year: "numeric",
  });
  return `${pluralize(bestDay.count, "hit")} on ${formatted}`;
}
</script>
