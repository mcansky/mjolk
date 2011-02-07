# Changelog

## 0.4

* fixed different cache problems
* improved the design
* added goo.gl shortener calls when adding a bookmark
* added followers/followed users
* added user groups
* added bookmarks cloning/copying from one user to another
* added gravatar support (using account email)

## 0.3.2

* fixed "My bookmarks" cache bug (pages)
* moved cache expiration calls from controllers to sweeper
* fixed stats display and split them into 3 differents graphs
* added rdoc/yard setup

## 0.3.1

* moved api code from posts controller to v1/posts controller
* fixed basic http auth
* cleaned and fixed api posts methods : all, get, add, delete. some are still needed
* fixed bookmarks destroy on user destroy

## 0.3

* added roles management
* upgraded all controllers for roles compatibility
* added beta accounts
* added mailers for account creation and administrative purposes
* replace rails_admin with a simple admin interface for users management
* added stats graphs using jquery flot lib

## 0.2.1

* fixed caching for user bookmarks
* added tags cloud
* changed menu

## 0.2

beta release

* improved caching
* improved tag browsing with fix for tag + username and tags cloud in user bookmarks

## 0.1

initial release : basic bookmarking.

* basic sign up using devise and registration
* basic sign in / auth using devise and oauth (twitter)
* basic bookmarking with tags
* username based browsing possible
* private bookmarks


## plans

* improve tags management with groups and synonyms
* improve api and dedicate a controller for it