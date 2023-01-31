const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        "umn-maroon": "#7a0019",
        "umn-maroon-dark": "#5b0013",
        "umn-gold": "#ffcc33",
        "umn-gold-light": "#ffde7a",
        "umn-neutral-50": "#f9f7f6", // page background color
        "umn-neutral-100": `#f0efee`, // gray for navbar
        "umn-neutral-200": `#d5d6d2`,
        "umn-neutral-500": `#737487`,
        "umn-neutral-700": `#5a5a5a`, // text color
        "umn-neutral-800": `#262626`, // active text color
        "umn-neutral-900": `#1a1a1a`,
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
  ],

  // add prefix to avoid conflicts with legacy css
  prefix: "tw-",
  corePlugins: {
    preflight: false,
  },
};
