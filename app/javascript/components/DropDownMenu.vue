<template>
  <Menu as="div" class="tw-relative tw-inline-block tw-text-left">
    <div>
      <MenuButton
        class="tw-inline-flex tw-w-full tw-justify-center tw-rounded-md tw-border tw-border-gray-300 tw-bg-white tw-px-4 tw-py-2 tw-text-sm tw-font-medium tw-text-gray-700 tw-shadow-sm hover:tw-bg-gray-50 focus:tw-outline-none focus:tw-ring-2 focus:tw-ring-indigo-500 focus:tw-ring-offset-2 focus:tw-ring-offset-gray-100"
      >
        {{ label }}
        <ChevronDownIcon
          class="tw--mr-1 tw-ml-2 tw-h-5 tw-w-5"
          aria-hidden="true"
        />
      </MenuButton>
    </div>

    <Transition
      enterActiveClass="tw-transition tw-ease-out tw-duration-100"
      enterFromClass="tw-transform tw-opacity-0 tw-scale-95"
      enterToClass="tw-transform tw-opacity-100 tw-scale-100"
      leaveActiveClass="tw-transition tw-ease-in tw-duration-75"
      leaveFromClass="tw-transform tw-opacity-100 tw-scale-100"
      leaveToClass="tw-transform tw-opacity-0 tw-scale-95"
    >
      <MenuItems
        class="tw-absolute tw-right-0 tw-z-10 tw-mt-2 tw-w-56 tw-origin-top-right tw-rounded-md tw-bg-white tw-shadow-lg tw-ring-1 tw-ring-black tw-ring-opacity-5 focus:tw-outline-none"
        :class="{
          'tw-left-0 tw-right-auto': align === 'left',
          'tw-right-0 tw-left-auto': align === 'right',
        }"
      >
        <div class="tw-py-1">
          <slot />
        </div>
      </MenuItems>
    </Transition>
  </Menu>
</template>

<script setup lang="ts">
import { Menu, MenuButton, MenuItems } from "@headlessui/vue";
import ChevronDownIcon from "@/icons/ChevronDownIcon.vue";

withDefaults(
  defineProps<{
    label: string;
    align?: "left" | "right";
  }>(),
  {
    align: "right",
  }
);
</script>
