<template>
  <PageLayout>
    <template #header>
      <p class="tw-uppercase tw-text-center">Admin</p>
      <h1>Collection: {{ group.name }}</h1>
    </template>
    <PostIt>
      <div class="tw-relative">
        <section class="tw-mb-8">
          <h2 class="tw-text-2xl tw-mb-4">Urls</h2>

          <AdminGroupUrlsDataTable :group="group" />
        </section>

        <section class="tw-mb-8">
          <h2 class="tw-text-2xl tw-mb-4">Members</h2>
          <AdminGroupMembersDataTable
            :group="group"
            :members="groupMembers"
            @addMember="handleAddGroupMember"
            @removeMember="handleRemoveGroupMember"
          />
        </section>
      </div>
    </PostIt>
  </PageLayout>
</template>
<script setup lang="ts">
import { ref } from "vue";
import PageLayout from "@/layouts/PageLayout.vue";
import { PostIt } from "@umn-latis/cla-vue-template";
import type { Collection, User } from "@/types";
import AdminGroupUrlsDataTable from "@/components/DataTables/AdminGroupUrlsDataTable.vue";
import AdminGroupMembersDataTable from "@/components/DataTables/AdminGroupMembersDataTable.vue";

const props = defineProps<{
  group: Collection;
  members: User[];
}>();

const groupMembers = ref<User[]>(props.members);

function handleAddGroupMember(user: User) {
  groupMembers.value.push(user);
}

function handleRemoveGroupMember(userId: number) {
  groupMembers.value = groupMembers.value.filter((user) => user.id !== userId);
}
</script>
<style scoped></style>
