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

// Tab configuration drives the chart tabs, chart bucketing, and summary
// stats table. `source` selects which server payload to read:
//   "hour" — clicks_by_hour (last 30d, hour precision). Needed for any
//            tab that buckets into local-timezone days.
//   "day"  — clicks_by_day (last 5y, day precision). Used for year/5y
//            tabs, which render monthly rollups.
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

// Truncate a date to the start of its containing bucket.
//   tz="local" — hourly-source tabs (24h/7d/30d). The server sends hour-
//     precise UTC instants; the client buckets them into the viewer's
//     local wall-clock so day/month boundaries align with local calendar.
//   tz="utc" — day-source tabs (year/5y). The server's daily keys are
//     UTC dates, so bucketing must stay in UTC. Otherwise a viewer west
//     of UTC would see the bucket shift backward by one day.
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

// Parse a "YYYY-MM-DD" daily-counts key as UTC midnight. The server
// produces these via MySQL's DATE(created_at), which is a UTC date (Rails
// stores datetimes as UTC). Keep the parsed instant in UTC so downstream
// bucketing/formatting can operate in UTC without drift.
function parseDayKey(key: string): Date {
  const [y, m, d] = key.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}

// Return the click entries from the tab's configured source that fall
// within the last `hoursBack` hours, as [Date, count] pairs. Used by
// tableRows to build chart and table data for the active tab.
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

// The display timezone is determined by the tab's source. Hour-source
// tabs display in the viewer's local tz (since we have hour precision to
// bucket correctly). Day-source tabs display in UTC, because the server's
// daily buckets are UTC dates and silently rebucketing them into local
// time would drift by up to a day near midnight.
const displayTz = computed<DisplayTz>(() =>
  activeTabConfig.value.source === "hour" ? "local" : "utc",
);

// Label for the display timezone, shown on the chart axis and table
// header so the viewer always knows what tz the numbers are in.
const displayTzLabel = computed(() =>
  displayTz.value === "utc" ? "UTC" : browserTimezoneShort,
);

const tableRows = computed<TableRow[]>(() => {
  if (!stats.value) return [];

  const { hoursBack, granularity, source } = activeTabConfig.value;
  const clicks = clicksWithin(hoursBack, source);
  const tz = displayTz.value;

  // Aggregate clicks into display buckets. Key by the millisecond
  // timestamp of the bucket start — unique, sortable, collision-free.
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

// Precomputed per-tab sums. One pass over clicks_by_hour accumulates into
// the hour-source tabs; one pass over clicks_by_day accumulates into the
// day-source tabs. Each tab only reads from its configured source, so the
// 30d/5y payloads stay cleanly separated.
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

// Best day is computed from clicks_by_day (the broadest window — up to
// 5 years). The server's daily buckets are UTC dates, so the displayed
// day is also UTC. The "(UTC)" label in the panel heading makes this
// explicit so viewers can reconcile it with their local calendar.
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
