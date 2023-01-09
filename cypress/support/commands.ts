// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************

import { RailsModel } from "../types";

/**
 * creates a rails-friendly stringified version of an object
 * Use this instead of JSON.stringify when passing objects
 * to rails, so that they object keys are symbols instead
 * of strings
 */

const stringifyObjectForRails = (obj: Record<string, string | Number>) =>
  "{" +
  Object.entries(obj)
    .map(([key, value]) => {
      const val = Number.isInteger(+value) ? value : `"${value}"`;
      return `${key}: ${val}`;
    })
    .join(", ") +
  "}";

/**
 * login a user
 * @see https://github.com/shakacode/cypress-on-rails/blob/master/docs/authentication.md
 */
function login(uid: string, redirect_to = "/") {
  if (!uid) throw new Error('You must pass a "uid" to login');

  return cy.visit("__cypress__/login", {
    method: "POST",
    body: { uid, redirect_to },
  });
}

/**
 * create a User via FactoryBot
 */
function createUser(uid: string, opts: Record<string, unknown> = {}) {
  return cy
    .appFactories<RailsModel.User>([["create", "user", { uid, ...opts }]])
    .then(([user]) => user);
}

/**
 * create a User via FactoryBot and login
 */
function createAndLoginUser(uid: string, opts: Record<string, unknown> = {}) {
  let user = null;
  return createUser(uid, opts)
    .then((u) => {
      user = u;
      login(uid);
    })
    .then(() => user);
}

/**
 * create an Announcement via FactoryBot
 */
function createAnnouncement(opts: Record<string, unknown> = {}) {
  return cy
    .appFactories<RailsModel.Announcement>([["create", "announcement", opts]])
    .then(([announcement]) => announcement);
}

function createUrl(partialUrl: Partial<RailsModel.Url>) {
  return cy
    .appFactories<RailsModel.Url>([["create", "url", partialUrl]])
    .then(([url]) => url);
}

/**
 * create Clicks for a given keyword
 */
function clickUrl(
  keyword: string,
  times = 1,
  clickOptions: Partial<RailsModel.Click> = {}
) {
  // NOTE: this function adds clicks rows directly to the
  // database for speed. An alternative would be to use
  // `cy.request` to hit the url, but we would need to do
  // request click individually and wait for the response
  // before moving on to the next request
  const clickOptionsString = stringifyObjectForRails(clickOptions);

  // create an array of stringified click options
  // that we can pass to clicks.create
  const clickOptionsArray = Array(times).fill(clickOptionsString);

  const createClicksInRailsCommand = `
    url = Url.find_by(keyword: "${keyword}")
    url.clicks.create(
      [${clickOptionsArray}]
    )
    url.total_clicks += ${times}
    url.save
  `;

  return cy.appEval(createClicksInRailsCommand);
}

function createGroup(name: string) {
  return cy
    .appFactories<RailsModel.Group>([["create", "group", { name }]])
    .then(([group]) => group);
}

function addUserToGroup(
  user: Pick<RailsModel.User, "umndid">,
  group: Pick<RailsModel.Group, "name">
) {
  return cy.appEval(`
    user = User.find_by(uid: "${user.umndid}")
    group = Group.find_by(name: "${group.name}")
    user.groups << group
  `);
}

function createGroupAndAddUser(
  groupName: string,
  user: Pick<RailsModel.User, "umndid">
) {
  let group;
  return createGroup(groupName)
    .then((grp) => {
      group = grp;
      addUserToGroup(user, grp);
    })
    .then(() => group);
}

Cypress.Commands.addAll({
  login,
  createUser,
  createAndLoginUser,
  createAnnouncement,
  createUrl,
  clickUrl,
  createGroup,
  addUserToGroup,
  createGroupAndAddUser,
});
