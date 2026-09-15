import { Zlink } from "@/types";

const EXTERNAL_LINK_ICON = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="tw-w-3 tw-h-3 tw-min-w-3 tw-min-h-3 tw-inline tw-aline-baseline">
  <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
</svg>`;

const GROUP_ICON = `<svg data-cy="group-icon" xmlns="http://www.w3.org/2000/svg" class="admin-urls-datatable__group-icon" fill="currentColor" stroke-width="1.5" stroke="currentColor" height="48" viewBox="0 96 960 960" width="48">
  <path d="M38 896v-94q0-35 18-63.5t50-42.5q73-32 131.5-46T358 636q62 0 120 14t131 46q32 14 50.5 42.5T678 802v94H38Zm700 0v-94q0-63-32-103.5T622 633q69 8 130 23.5t99 35.5q33 19 52 47t19 63v94H738ZM358 575q-66 0-108-42t-42-108q0-66 42-108t108-42q66 0 108 42t42 108q0 66-42 108t-108 42Zm360-150q0 66-42 108t-108 42q-11 0-24.5-1.5T519 568q24-25 36.5-61.5T568 425q0-45-12.5-79.5T519 282q11-3 24.5-5t24.5-2q66 0 108 42t42 108ZM98 836h520v-34q0-16-9.5-31T585 750q-72-32-121-43t-106-11q-57 0-106.5 11T130 750q-14 6-23 21t-9 31v34Zm260-321q39 0 64.5-25.5T448 425q0-39-25.5-64.5T358 335q-39 0-64.5 25.5T268 425q0 39 25.5 64.5T358 515Zm0 321Zm0-411Z"/>
</svg>`;

function peopleSearchUrl(internetId: string): string {
  return `https://udirectory.umn.edu/lookup?type=Internet+ID&CN=${internetId}&campus=a&role=any`;
}

function ownerPersonLink(internetId: string): string {
  // truncate the name, not the anchor: moving this
  // class to the <a> clips the external-link icon
  return `<a
      data-cy="owner-person-link"
      class="tw-inline-flex tw-items-center tw-gap-1"
      title="${internetId}"
      href="${peopleSearchUrl(internetId)}"
      target="_blank"
      rel="noopener noreferrer nofollow"
    ><span class="admin-urls-datatable__group-col">${internetId}</span>${EXTERNAL_LINK_ICON}</a>`;
}

function groupMembersLink(groupName: string, groupId: string): string {
  return `<a
      class="admin-urls-datatable__group-col"
      title="${groupName}"
      href="/shortener/groups/${groupId}/members"
    >${GROUP_ICON}<span>${groupName}</span></a>`;
}

export function renderOwnerCell(row: Zlink): string {
  // "false" is truthy, so a truthiness check here
  // links every collection to people search
  const isDefaultGroup = row.is_default_group === "true";

  if (isDefaultGroup) return ownerPersonLink(row.group_name);
  return groupMembersLink(row.group_name, row.group_id);
}
