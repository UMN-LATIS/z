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

      <!-- Summary stats — one row per tab -->
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
          <tr v-for="tab in tabs" :key="tab.key">
            <td>{{ tab.label }}</td>
            <td>{{ pluralize(sumClicks(tab.key), "hit") }}</td>
            <td>
              {{ avgClicks(tab.key).toFixed(2) }} per
              {{ tab.averageUnit }}
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="bestDay" class="panel panel-default">
        <h2 class="panel-heading tw-mb-0 tw-text-base tw-text-left">
          Best Day
        </h2>
        <div class="panel-body">
          {{ formatBestDay(bestDay) }}
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

const HOUR_MS = 60 * 60 * 1000;

// Tab configuration drives the chart tabs, the chart bucketing, and the
// summary stats table. hoursBack is the time window; granularity is how to
// group clicks for display; averageDivisor is the denominator for the
// per-period average.
const tabs = [
  {
    key: "hrs24",
    label: "Last 24 Hours",
    axisLabel: "Time",
    hoursBack: 24,
    granularity: "hour",
    averageUnit: "hour",
    averageDivisor: 24,
  },
  {
    key: "days7",
    label: "Last 7 Days",
    axisLabel: "Date",
    hoursBack: 24 * 7,
    granularity: "day",
    averageUnit: "day",
    averageDivisor: 7,
  },
  {
    key: "days30",
    label: "Last 30 Days",
    axisLabel: "Date",
    hoursBack: 24 * 30,
    granularity: "day",
    averageUnit: "day",
    averageDivisor: 30,
  },
  {
    key: "year",
    label: "Last Year",
    axisLabel: "Month",
    hoursBack: 24 * 365,
    granularity: "month",
    averageUnit: "month",
    averageDivisor: 12,
  },
  {
    key: "years5",
    label: "Last 5 Years",
    axisLabel: "Month",
    hoursBack: 24 * 365 * 5,
    granularity: "month",
    averageUnit: "month",
    averageDivisor: 60,
  },
] as const satisfies readonly {
  key: string;
  label: string;
  axisLabel: string;
  hoursBack: number;
  granularity: ClickGranularity;
  averageUnit: string;
  averageDivisor: number;
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

// Return the hourly click entries that fall within the last `hoursBack`
// hours, as [Date, count] pairs. Reused by chart data, summary stats, and
// best-day computation.
function clicksWithin(hoursBack: number): Array<[Date, number]> {
  if (!stats.value) return [];
  const cutoff = Date.now() - hoursBack * HOUR_MS;
  const result: Array<[Date, number]> = [];
  for (const [iso, count] of Object.entries(stats.value.clicks_by_hour)) {
    const date = new Date(iso);
    if (date.getTime() >= cutoff) {
      result.push([date, count]);
    }
  }
  return result;
}

interface TableRow {
  iso: string;
  label: string;
  count: number;
}

const tableRows = computed<TableRow[]>(() => {
  if (!stats.value) return [];

  const { hoursBack, granularity } = activeTabConfig.value;
  const clicks = clicksWithin(hoursBack);

  // Aggregate hourly clicks into local-time display buckets. Key by the
  // millisecond timestamp of the local bucket start — unique, sortable,
  // and collision-free for different local buckets.
  const buckets = new Map<number, { start: Date; count: number }>();

  for (const [date, count] of clicks) {
    const start = bucketStart(date, granularity);
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

// Precomputed per-tab sums. Uses a single pass over clicks_by_hour to
// populate all tabs at once, so re-rendering the summary table doesn't
// re-iterate the click hash N times.
const clickSumsByTab = computed<Record<TabKey, number>>(() => {
  const sums = Object.fromEntries(tabs.map((t) => [t.key, 0])) as Record<
    TabKey,
    number
  >;
  if (!stats.value) return sums;

  const now = Date.now();
  for (const [iso, count] of Object.entries(stats.value.clicks_by_hour)) {
    const age = now - new Date(iso).getTime();
    for (const tab of tabs) {
      if (age <= tab.hoursBack * HOUR_MS) {
        sums[tab.key] += count;
      }
    }
  }
  return sums;
});

function sumClicks(key: TabKey): number {
  return clickSumsByTab.value[key];
}

function avgClicks(key: TabKey): number {
  const tab = tabs.find((t) => t.key === key)!;
  return sumClicks(key) / tab.averageDivisor;
}

// Best day is computed in the viewer's local timezone — aggregate every
// hourly click into the local day that contains it, then find the max.
const bestDay = computed<{ date: Date; count: number } | null>(() => {
  if (!stats.value) return null;

  const byLocalDay = new Map<number, { start: Date; count: number }>();
  for (const [iso, count] of Object.entries(stats.value.clicks_by_hour)) {
    const date = new Date(iso);
    const start = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const key = start.getTime();
    const existing = byLocalDay.get(key);
    if (existing) {
      existing.count += count;
    } else {
      byLocalDay.set(key, { start, count });
    }
  }

  let best: { start: Date; count: number } | null = null;
  for (const bucket of byLocalDay.values()) {
    if (!best || bucket.count > best.count) best = bucket;
  }
  return best ? { date: best.start, count: best.count } : null;
});

function pluralize(count: number, singular: string): string {
  return `${count} ${count === 1 ? singular : singular + "s"}`;
}

function formatBestDay(best: { date: Date; count: number }): string {
  const formatted = best.date.toLocaleDateString(undefined, {
    month: "long",
    day: "numeric",
    year: "numeric",
  });
  return `${pluralize(best.count, "hit")} on ${formatted}`;
}
</script>
