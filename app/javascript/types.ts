import {
  type Config as DTOptions,
  type Api as DTApi,
  type ConfigColumns as DTColumnOptions,
} from "datatables.net";

export type DataTableApi<T = object> = DTApi<T>;
export type DataTableOptions = DTOptions;
export type DataTableColumnOptions = DTColumnOptions;

type DateTimeString = string;

export interface User {
  id: number;
  uid?: string;
  default_group_id?: number;
  admin?: null;
  display_name?: string;
  email?: string;
  internet_id?: string;
  created_at?: DateTimeString;
  updated_at?: DateTimeString;
}

export interface Collection {
  id: string;
  name: string;
  description: string;
  created_at: string;
  updated_at: string;
  urls?: Zlink[];
  users?: User[]; // collection members
}

export interface Zlink {
  id: number;
  keyword: string;
  url: string;
  created_at: string;
  updated_at: string;
  group_id: string;
  group_name: string;
  total_clicks?: number;
}

export type ClickGranularity = "hour" | "day" | "month";

// Raw hourly click series from the server: { iso_utc_timestamp => count }.
// Only hours with at least one click are included.
export type ClickSeries = Record<string, number>;

export interface UrlStatsResponse {
  url: {
    id: number;
    keyword: string;
    created_at: string;
    total_clicks: number;
  };
  clicks: {
    hrs24: ClickSeries;
    days7: ClickSeries;
    days30: ClickSeries;
    year: ClickSeries;
    years5: ClickSeries;
  };
  best_day: { date: string; count: number } | null;
}

export interface LookupUserResponse {
  umndid: string;
  display: string;
  internet_id: string;
  display_name: string;
}

export interface TransferRequest {
  id: number;
  to_group_id: number;
  from_group_id: number;
  from_group_requestor_id: number;
  key: null;
  status: "pending" | "approved" | "rejected";
  created_at: DateTimeString;
  updated_at: DateTimeString;
}
