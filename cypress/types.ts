export namespace RailsModel {
  export interface User {
    id: number;
    umndid: string;
    display: string;
    internet_id: string;
    display_name: string;
    group_id: number;
  }

  export interface Announcement {
    id: number;
    title: string;
    body: string;
    start_delivering_at: string; // ISO8601
    stop_delivering_at: string; // ISO8601
  }

  export interface Url {
    id: number;
    group_id: number;
    keyword: string;
    url: string;
  }
}

export type RailsAppFactoriesCommand = [
  string,
  string,
  Record<string, unknown>
];
