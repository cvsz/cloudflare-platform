import registry from "../integrations.registry.json";
import "./integration-map.css";

const priorityRank = { P0: 0, P1: 1, P2: 2, P3: 3 };

function createNode(tagName, className, text) {
  const node = document.createElement(tagName);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function repoUrl(repo) {
  return `https://github.com/${repo}`;
}

function createRepoLink(repo) {
  const link = createNode("a", "integration-repo", repo);
  link.href = repoUrl(repo);
  link.target = "_blank";
  link.rel = "noreferrer noopener";
  return link;
}

function createMetric(label, value, tone) {
  const card = createNode("article", `integration-metric tone-${tone}`);
  card.append(createNode("span", "", label));
  card.append(createNode("strong", "", value));
  return card;
}

function createTargetCard(target) {
  const card = createNode("article", `integration-card priority-${target.priority.toLowerCase()}`);
  const top = createNode("div", "integration-card-top");
  const titleWrap = createNode("div");
  const title = createNode("h3", "", target.module);
  const mode = createNode("p", "", target.mode);
  const priority = createNode("span", "integration-priority", target.priority);

  titleWrap.append(title, mode);
  top.append(titleWrap, priority);
  card.append(top);

  const panelTitle = createNode("div", "integration-label", "zDash panels");
  const panelList = createNode("div", "integration-pills");
  target.zdash_panels.forEach((panel) => panelList.append(createNode("span", "integration-pill", panel)));
  card.append(panelTitle, panelList);

  const repoTitle = createNode("div", "integration-label", "source repos");
  const repoList = createNode("div", "integration-repos");
  target.repos.forEach((repo) => repoList.append(createRepoLink(repo)));
  card.append(repoTitle, repoList);

  return card;
}

function buildIntegrationSection() {
  const targets = [...registry.integration_targets].sort((left, right) => {
    const priorityDelta = priorityRank[left.priority] - priorityRank[right.priority];
    return priorityDelta || left.module.localeCompare(right.module);
  });
  const uniqueRepos = new Set(targets.flatMap((target) => target.repos));
  const priorityCounts = targets.reduce((accumulator, target) => {
    accumulator[target.priority] = (accumulator[target.priority] || 0) + 1;
    return accumulator;
  }, {});

  const section = createNode("section", "section zdash-integration-map");
  section.id = "integration-map";

  section.append(createNode("div", "section-title", "11 — INTEGRATION MAP"));
  section.append(createNode("h2", "section-heading", "Repository Integration Map"));
  section.append(createNode("p", "section-sub", "Live source-of-truth registry for wiring cvsz/* and ZeaZDev/* systems into zDash through safe adapters instead of vendoring whole repositories."));

  const metrics = createNode("div", "integration-metrics");
  metrics.append(
    createMetric("Integration modules", String(targets.length), "gold"),
    createMetric("Source repositories", String(uniqueRepos.size), "cyan"),
    createMetric("P0 targets", String(priorityCounts.P0 || 0), "green"),
    createMetric("Public route", registry.public_url.replace("https://", ""), "purple")
  );
  section.append(metrics);

  const grid = createNode("div", "integration-grid");
  targets.forEach((target) => grid.append(createTargetCard(target)));
  section.append(grid);

  const footer = createNode("div", "integration-footer");
  footer.append(createNode("span", "", `Owner repo: ${registry.owner_repo}`));
  footer.append(createNode("span", "", `Local service: ${registry.local_service}`));
  section.append(footer);

  return section;
}

function mountIntegrationMap() {
  const main = document.querySelector("main.container") || document.querySelector("main.shell");
  if (!main) {
    window.setTimeout(mountIntegrationMap, 50);
    return;
  }

  if (document.getElementById("integration-map")) return;

  const section = buildIntegrationSection();
  const footer = main.querySelector("footer");
  if (footer) {
    main.insertBefore(section, footer);
  } else {
    main.append(section);
  }
}

mountIntegrationMap();
