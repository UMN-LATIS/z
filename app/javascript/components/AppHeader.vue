<template>
  <ClaAppHeader>
    <template #app-link>
      <a href="/">Z</a>
    </template>
    <template #navbar-links-right>
      <template v-if="isLoggedIn">
        <NavbarItem>
          <a href="/shortener/urls">My Z-Links</a>
        </NavbarItem>
        <NavbarItem>
          <a href="/shortener/groups">My Collections</a>
        </NavbarItem>
        <NavbarItem>
          <a href="/shortener/api_keys">API</a>
        </NavbarItem>
        <NavbarDropdown v-if="isAdmin" label="Admin">
          <NavbarItem>
            <a href="https://z.umn.edu/shortener/admin/urls">All Urls</a>
          </NavbarItem>
          <NavbarItem>
            <a href="https://z.umn.edu/shortener/admin/groups">
              All Collections
            </a>
          </NavbarItem>
          <NavbarItem>
            <a href="https://z.umn.edu/shortener/admin/members">
              Manage Admins
            </a>
          </NavbarItem>
          <NavbarItem>
            <a href="https://z.umn.edu/shortener/admin/audits"> Audit Logs </a>
          </NavbarItem>
          <NavbarItem>
            <a href="https://z.umn.edu/shortener/admin/announcements">
              Announcements
            </a>
          </NavbarItem>
        </NavbarDropdown>
      </template>
      <NavbarItem>
        <a
          href="https://it.umn.edu/services-technologies/how-tos/z-links-create-manage-z-links"
          >Help</a
        >
      </NavbarItem>
      <NavbarItem v-if="!isLoggedIn">
        <a href="/shortener/signin">Sign In</a>
      </NavbarItem>
      <NavbarItem v-if="isLoggedIn">
        <a href="/shortener/signout">Sign Out</a>
      </NavbarItem>
    </template>
  </ClaAppHeader>
</template>
<script setup lang="ts">
import {
  AppHeader as ClaAppHeader,
  NavbarItem,
  NavbarDropdown,
} from "@umn-latis/cla-vue-template";
import { computed } from "vue";
import type { User } from "@/types";

const props = withDefaults(
  defineProps<{
    currentUser: User | null;
  }>(),
  {
    currentUser: null,
  }
);

const isLoggedIn = computed(() => props.currentUser !== null);
const isAdmin = computed(() => props.currentUser?.admin ?? false);
</script>
<style scoped></style>
