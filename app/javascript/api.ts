import axios, { AxiosError } from "axios";
import {
  Collection,
  LookupUserResponse,
  TransferRequest,
  User,
  Zlink,
} from "@/types";

// set the CSRF token for all axios requests
const csrfToken = (
  document.querySelector("[name=csrf-token]") as HTMLMetaElement
).content;

axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;
axios.defaults.headers.common["Content-Type"] = "application/json";
axios.defaults.headers.common["Accept"] = "application/json";

interface ApiResponse<DataType = object, ErrorType = string> {
  success: boolean;
  data?: DataType;
  errors?: ErrorType[];
  message?: string;
}

function handleAxiosError(error: AxiosError) {
  // The request was made and the server responded with a status code
  // that falls out of the range of 2xx
  if (error.response) {
    return {
      success: false,
      errors: Array.isArray(error.response.data)
        ? error.response.data
        : [error.response.data],
    };
  }

  // The request was made but no response was received
  if (error.request) {
    return { success: false, errors: ["No response received from server"] };
  }

  // Something happened in setting up the request that triggered an Error
  return { success: false, errors: [error.message] };
}

export function updateUrl(
  id,
  updatedZlink: Pick<Zlink, "url" | "keyword">
): Promise<ApiResponse<Zlink>> {
  return axios
    .patch<Zlink>(`/shortener/urls/${id}`, {
      url: updatedZlink,
    })
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function updateCollection(
  collection: Partial<Collection>
): Promise<ApiResponse<Collection>> {
  return axios
    .patch<Collection>(`/shortener/groups/${collection.id}`, collection)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function deleteCollection(id: number): Promise<ApiResponse<Collection>> {
  return axios
    .delete(`/shortener/groups/${id}`)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function createCollection(
  collection: Partial<Collection>
): Promise<ApiResponse<Collection>> {
  return axios
    .post<Collection>("/shortener/groups", collection)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function getCollection(id: number): Promise<ApiResponse<Collection>> {
  return axios
    .get<Collection>(`/shortener/groups/${id}`)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function getMembersOfCollection(
  id: number
): Promise<ApiResponse<User[]>> {
  return axios
    .get<User[]>(`/shortener/groups/${id}/members`)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function lookupUsers(
  query: string
): Promise<ApiResponse<LookupUserResponse[]>> {
  return axios
    .get<LookupUserResponse[]>(`/shortener/lookup_users?search_terms=${query}`)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function bulkTransferUrlsToUser(
  keywords: string[],
  user: Pick<LookupUserResponse, "umndid">
): Promise<ApiResponse<TransferRequest>> {
  return axios
    .post<TransferRequest>("/shortener/admin/transfer_requests", {
      transfer_request: {
        to_group: user.umndid,
      },
      keywords,
    })
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}