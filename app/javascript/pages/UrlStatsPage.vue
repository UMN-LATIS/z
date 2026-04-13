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
                {{ activeTabConfig.axisLabel }} ({{ displayTzLabel }})
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
          Best Day (UTC)
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

// source: "hour" reads clicks_by_hour, "day" reads clicks_by_day.
const tabs = [
  {
    key: "hrs24",
    label: "Last 24 Hours",
    axisLabel: "Time",
    hoursBack: 24,
    granularity: "hour",
    source: "hour",
    averageUnit: "hour",
    averageDivisor: 24,
  },
  {
    key: "days7",
    label: "Last 7 Days",
    axisLabel: "Date",
    hoursBack: 24 * 7,
    granularity: "day",
    source: "hour",
    averageUnit: "day",
    averageDivisor: 7,
  },
  {
    key: "days30",
    label: "Last 30 Days",
    axisLabel: "Date",
    hoursBack: 24 * 30,
    granularity: "day",
    source: "hour",
    averageUnit: "day",
    averageDivisor: 30,
  },
  {
    key: "year",
    label: "Last Year",
    axisLabel: "Month",
    hoursBack: 24 * 365,
    granularity: "month",
    source: "day",
    averageUnit: "month",
    averageDivisor: 12,
  },
  {
    key: "years5",
    label: "Last 5 Years",
    axisLabel: "Month",
    hoursBack: 24 * 365 * 5,
    granularity: "month",
    source: "day",
    averageUnit: "month",
    averageDivisor: 60,
  },
] as const satisfies readonly {
  key: string;
  label: string;
  axisLabel: string;
  hoursBack: number;
  granularity: ClickGranularity;
  source: "hour" | "day";
  averageUnit: string;
  averageDivisor: number;
}[];

type TabKey = (typeof tabs)[number]["key"];

const activeTab = ref<TabKey>("hrs24");
const stats = ref<UrlStatsResponse | null>(null);
const loading = ref(true);
const error = ref<string | null>(null);

const browserTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;

// e.g. "CDT"
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

function formatBucket(
  date: Date,
  granularity: ClickGranularity,
  tz: DisplayTz,
): string {
  const tzOpt = tz === "utc" ? { timeZone: "UTC" } : {};
  switch (granularity) {
    case "hour":
      return date.toLocaleTimeString(undefined, {
        hour: "numeric",
        minute: "2-digit",
        ...tzOpt,
      });
    case "day":
      return date.toLocaleDateString(undefined, {
        month: "numeric",
        day: "numeric",
        ...tzOpt,
      });
    case "month":
      return date.toLocaleDateString(undefined, {
        month: "short",
        year: "numeric",
        ...tzOpt,
      });
  }
}

type DisplayTz = "local" | "utc";

// Truncate a date to the start of its containing bucket in local or UTC.
function bucketStart(
  date: Date,
  granularity: ClickGranularity,
  tz: DisplayTz,
): Date {
  if (tz === "utc") {
    switch (granularity) {
      case "hour":
        return new Date(
          Date.UTC(
            date.getUTCFullYear(),
            date.getUTCMonth(),
            date.getUTCDate(),
            date.getUTCHours(),
          ),
        );
      case "day":
        return new Date(
          Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
        );
      case "month":
        return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), 1));
    }
  }
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

// Parse "YYYY-MM-DD" as UTC midnight.
function parseDayKey(key: string): Date {
  const [y, m, d] = key.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}

function clicksWithin(
  hoursBack: number,
  source: "hour" | "day",
): Array<[Date, number]> {
  if (!stats.value) return [];
  const cutoff = Date.now() - hoursBack * HOUR_MS;
  const entries =
    source === "hour"
      ? Object.entries(stats.value.clicks_by_hour).map(
          ([iso, count]) => [new Date(iso), count] as [Date, number],
        )
      : Object.entries(stats.value.clicks_by_day).map(
          ([key, count]) => [parseDayKey(key), count] as [Date, number],
        );
  return entries.filter(([date]) => date.getTime() >= cutoff);
}

interface TableRow {
  iso: string;
  label: string;
  count: number;
}

// Hour-source tabs show local tz; day-source tabs show UTC (daily buckets
// are UTC dates, rebucketing to local would drift near midnight).
const displayTz = computed<DisplayTz>(() =>
  activeTabConfig.value.source === "hour" ? "local" : "utc",
);

const displayTzLabel = computed(() =>
  displayTz.value === "utc" ? "UTC" : browserTimezoneShort,
);

const tableRows = computed<TableRow[]>(() => {
  if (!stats.value) return [];

  const { hoursBack, granularity, source } = activeTabConfig.value;
  const clicks = clicksWithin(hoursBack, source);
  const tz = displayTz.value;

  const buckets = new Map<number, { start: Date; count: number }>();

  for (const [date, count] of clicks) {
    const start = bucketStart(date, granularity, tz);
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
      label: formatBucket(start, granularity, tz),
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
        text: `${activeTabConfig.value.axisLabel} (${displayTzLabel.value})`,
      },
    },
    y: { title: { display: true, text: "Clicks" }, beginAtZero: true },
  },
}));

const clickSumsByTab = computed<Record<TabKey, number>>(() => {
  const sums = Object.fromEntries(tabs.map((t) => [t.key, 0])) as Record<
    TabKey,
    number
  >;
  if (!stats.value) return sums;

  const now = Date.now();
  const hourTabs = tabs.filter((t) => t.source === "hour");
  const dayTabs = tabs.filter((t) => t.source === "day");

  for (const [iso, count] of Object.entries(stats.value.clicks_by_hour)) {
    const age = now - new Date(iso).getTime();
    for (const tab of hourTabs) {
      if (age <= tab.hoursBack * HOUR_MS) {
        sums[tab.key] += count;
      }
    }
  }
  for (const [key, count] of Object.entries(stats.value.clicks_by_day)) {
    const age = now - parseDayKey(key).getTime();
    for (const tab of dayTabs) {
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

const bestDay = computed<{ date: Date; count: number } | null>(() => {
  if (!stats.value) return null;

  let best: { date: Date; count: number } | null = null;
  for (const [key, count] of Object.entries(stats.value.clicks_by_day)) {
    if (!best || count > best.count) {
      best = { date: parseDayKey(key), count };
    }
  }
  return best;
});

function pluralize(count: number, singular: string): string {
  return `${count} ${count === 1 ? singular : singular + "s"}`;
}

function formatBestDay(best: { date: Date; count: number }): string {
  const formatted = best.date.toLocaleDateString(undefined, {
    month: "long",
    day: "numeric",
    year: "numeric",
    timeZone: "UTC",
  });
  return `${pluralize(best.count, "hit")} on ${formatted}`;
}
</script>
