<template>
  <ClaAppHeader>
    <template #app-link>
      <a href="/">Z</a>
    </template>
    <template #navbar-links>
      <slot name="navbar-left" />
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
        <NavbarItem v-if="isAdmin">
          <a href="/shortener/admin/urls">Admin</a>
        </NavbarItem>
      </template>
      <NavbarItem>
        <a
          href="https://it.umn.edu/services-technologies/how-tos/z-links-create-manage-z-links"
          >Help</a
        >
      </NavbarItem>
      <NavbarItem v-if="!isLoggedIn">
        <a href="/login">Sign In</a>
      </NavbarItem>
      <NavbarItem v-if="isLoggedIn">
        <a href="/shibboleth-logout">Sign Out</a>
      </NavbarItem>
    </template>
  </ClaAppHeader>
</template>
<script setup lang="ts">
import {
  AppHeader as ClaAppHeader,
  NavbarItem,
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
