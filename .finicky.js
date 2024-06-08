module.exports = {
  defaultBrowser: "Google Chrome",
  options: {
    hideIcon: false,
    checkForUpdate: true,
  },
  handlers: [
    {
      match: ({ opener }) =>
        ["Slack"].includes(opener.name),
      browser: {
        name: "Google Chrome",
        profile: "Profile 1",
      },
    },
    {
      match: ({ url }) => url.protocol === "slack",
      browser: "/Applications/Slack.app",
    },
  ],
};
