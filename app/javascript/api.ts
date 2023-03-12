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
  errors?: ErrorType;
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

interface UpdateUrlErrors {
  keyword?: string[];
  url?: string[];
  messages?: string[];
}

export function updateUrl(
  id,
  updatedZlink: Pick<Zlink, "url" | "keyword">
): Promise<ApiResponse<Zlink, UpdateUrlErrors>> {
  return axios
    .patch<Zlink>(`/shortener/urls/${id}`, {
      url: updatedZlink,
    })
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch((err) => {
      if (err.response) {
        return {
          success: false,
          errors: err.response.data as UpdateUrlErrors,
        };
      }
      return {
        success: false,
        errors: { messages: [err.message] as string[] },
      };
    });
}

export function deleteUrl(id): Promise<ApiResponse<Zlink, string[]>> {
  return axios
    .delete(`/shortener/urls/${id}`)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function updateCollection(
  collection: Partial<Collection>
): Promise<ApiResponse<Collection, string[]>> {
  return axios
    .patch<Collection>(`/shortener/groups/${collection.id}`, collection)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function deleteCollection(
  id: number
): Promise<ApiResponse<Collection, string[]>> {
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
): Promise<ApiResponse<Collection, string[]>> {
  return axios
    .post<Collection>("/shortener/groups", collection)
    .then((res) => ({
      success: true,
      data: res.data,
    }))
    .catch(handleAxiosError);
}

export function getCollection(
  id: number
): Promise<ApiResponse<Collection, string[]>> {
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
): Promise<ApiResponse<User[], string[]>> {
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
): Promise<ApiResponse<LookupUserResponse[], string[]>> {
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
): Promise<ApiResponse<TransferRequest, string[]>> {
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

export function removeUserFromCollection(
  userId: number,
  collectionId: number | string
) {
  alert("removeUserFromCollection not implemented");
  // return axios
  //   .delete(`/shortener/groups/${collectionId}/members/${userId}`)
  //   .then((res) => ({
  //     success: true,
  //     data: res.data,
  //   }))
  //   .catch(handleAxiosError);
}

export function addUserToCollection(
  userId: number,
  collectionId: number | string
) {
  alert("addUserToCollection not implemented");
  // return axios
  //   .post(`/shortener/groups/${collectionId}/members`, {
  //     user_id: userId,
  //   })
  //   .then((res) => ({
  //     success: true,
  //     data: res.data,
  //   }))
  //   .catch(handleAxiosError);
}

export function removeUrlFromCollection(
  urlId: number,
  collectionId: number | string
) {
  alert("removeUrlFromCollection not implemented");
  // return axios
  //   .delete(`/shortener/groups/${collectionId}/urls/${urlId}`)
  //   .then((res) => ({
  //     success: true,
  //     data: res.data,
  //   }))
  //   .catch(handleAxiosError);
}

export function addUrlToCollection(
  urlId: number,
  collectionId: number | string
) {
  alert("addUrlToCollection not implemented");
  // return axios
  //   .post(`/shortener/groups/${collectionId}/urls`, {
  //     url_id: urlId,
  //   })
  //   .then((res) => ({
  //     success: true,
  //     data: res.data,
  //   }))
  //   .catch(handleAxiosError);
}
