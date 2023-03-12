<template>
  <PageLayout>
    <template #header>
      <p class="tw-uppercase tw-text-center">Admin</p>
      <h1>All Collections</h1>
    </template>
    <PostIt>
      <div class="tw-relative">
        <h2>Collection: {{ group.name }}</h2>

        <h3>Urls</h3>
        <ul>
          <li v-for="url in group.urls" :key="url.id">
            {{ url.url }}
          </li>
        </ul>

        <h3>Members</h3>
        <ul>
          <li v-for="member in members" :key="member.id">
            {{ member.name }}
          </li>
        </ul>

        <pre>{{ group }}</pre>
        <pre>{{ members }}</pre>

        <!-- <DataTable
          ref="table"
          data-cy="groups-table"
          class="table table-striped table-bordered !tw-w-full"
          :options="options"
          :columns="columns"
          :headers="['ID', 'Name', 'Urls', 'Members', 'Actions']"
          @mounted="handleDataTableMounted"
          @click="handleDataTableClick"
        /> -->
      </div>
    </PostIt>
  </PageLayout>
</template>
<script setup lang="ts">
import { ref } from "vue";
import Modal from "@/components/Modal.vue";
import ConfirmDangerModal from "@/components/ConfirmDangerModal.vue";
import DataTable from "@/components/DataTable.vue";
import EditGroupForm from "@/components/EditGroupForm.vue";
import * as api from "@/api";
import PageLayout from "@/layouts/PageLayout.vue";
import { PostIt } from "@umn-latis/cla-vue-template";
import type {
  Collection,
  User,
  Zlink,
  DataTableApi,
  DataTableOptions,
  DataTableColumnOptions,
} from "@/types";

defineProps<{
  group: Collection;
  members: User[];
}>();
</script>
<style scoped></style>
