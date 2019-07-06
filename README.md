# Orbis


## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Identifies the best and safest route for the user.

### App Evaluation
[Evaluation of your app across the following attributes]
- Category: Navigation/Safety
- Mobile: Mobile version
- Story: Everyday, people face the issue of finding the best or safe route, no matter where they are. This app helps people identify the safest route. 
- Market: This app is geared towards invidiuals who find themselves unsure or uncomfortable about the areas surrounding them; big cities like San Francisco and New York City are often very overwhelming so it can be easy for people such as tourists to accidentally find thsmelves in relatively dangerous zones of the city.
- Habit: Used for the purpose of navigation, not addictive
- Scope: Easy to use interface, utilizes data to identify best routes for user

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- Upon luanching app, load a map of the United States coupled with a search bar
- User can input the city they are located; map zooms into this city/region
- User can specify their current location and destination
- Identifies three routes the user can take (based on different safety levels) and has tab navigation that allows user to toggle between different routes
- Have a little info screen specifying disclaimer, identifying resources used, thereby ensuring transparency to users


**Optional Nice-to-have Stories**

- Implement a settings page and allow for all of these features to be present in app if user selects the feature: 
    - Automatically calls 911 if user is deemed "in danger" (doesn't get to destination within timeframe)
    - Shows estimated travel time for each of the three routes
    - Login, logout, and user profile for most traveled routes previously
    - Take audio recordings and take pictures 
- Customize UI to look professional

### 2. Screen Archetypes
#### Required Screens
Note: Will need to think about transitions, views, and animations, we'll use 
* Splash/Full Map Screen
   * load a map of the United States
   * display a search bar above the map to allow for city input
* Zoomed-in Map/City Map
   * search bar will now display "input destination"
   * the map should be zoomed into the specified city and now display "hot zones" and relative safety of areas
 * Route Map
   * map will now display routes of different saftey levels and display estimated arrival times for each
   * has tab bar that allows user to choose one of the three routes to view on the map

#### Optional Screens
* Settings 
    * user can configure app settings (see optional features above)
* Login / Register
    * user can create an account and save their most traveled routes 

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* On the Route Map, we'll have a tab bar that allows user to toggle between the three routes. 

**Flow Navigation** (Screen to Screen)

* Login Screen (optional)
   => Splash Screen/Full Map Screen
 * Splash Screen/Full Map Screen (required)
   => Zoomed-in Map/City Map
 * Zoomed-in Map/City Map
   => Routes Map that has tab navigation
   
## Wireframes

https://github.com/orbisfbu/Orbis/tree/master/Image_Assets

# Helpful Stuff:

- https://nextcity.org/daily/entry/pedestrian-open-data-safest-shortest-walk-map Sketch Factor approached this problem the wrong way, they used user reports instead of using actual data. We intend on obtaining a non-biased dataset from reliable sources such as FBI APIs.
- An example model: http://www2.cs.uic.edu/~urbcomp2013/urbcomp2014/papers/Galbrun_Safe%20Navigation.pdf
-  https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2 Crime data in Chicago
-  https://data.cityofnewyork.us/Public-Safety/NYPD-Complaint-Data-Historic/qgea-i56i Crime data in NYC
-  https://www.ft.com/content/fecb0c38-c0dc-11e8-8d55-54197280d3f7 Article on whether Google Maps sghould plan safer routes.
# Data for SF: 
-  https://data.sfgov.org/Public-Safety/Police-Department-Incident-Reports-Historical-2003/tmnf-yvry
-  https://dev.socrata.com/foundry/data.sfgov.org/wg3w-h783

