import type { StrapiApp } from '@strapi/strapi/admin';

export default {
  config: {
    translations: {
      en: {
        "app.components.HomePage.welcome.title": "Hey Shivam, Welcome to Strapi",
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