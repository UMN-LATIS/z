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

function createUrl({
  keyword,
  url,
  user,
}: {
  keyword: string;
  url: string;
  user: RailsModel.User;
}) {
  return cy
    .appFactories<RailsModel.Url>([
      ["create", "url", { group_id: user.context_group_id, keyword, url }],
    ])
    .then(([url]) => url);
}

function clickUrl(keyword: string, times = 1) {
  // there may be better ways to do this, but it works
  const urlsToClick: string[] = Array(times).fill(`/${keyword}`);
  cy.wrap(urlsToClick).each((url: string) => cy.request(url));
}

Cypress.Commands.addAll({
  login,
  createUser,
  createAndLoginUser,
  createAnnouncement,
  createUrl,
  clickUrl,
});
