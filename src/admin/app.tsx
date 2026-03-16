import type { StrapiApp } from '@strapi/strapi/admin';

export default {
  config: {
    // 1. Add the translations object here
    translations: {
      en: {
        "app.components.HomePage.welcome.title": "Hey Shivam, Welcome Back!",
        "app.components.HomePage.welcome.subtitle": "This is your custom administration panel.",
        "app.components.HomePage.button.blog": "View Documentation",
      },
    },
    locales: [],
  },
  bootstrap(app: StrapiApp) {
    console.log(app);
  },
};