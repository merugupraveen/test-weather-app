Feature: Weather Service
  As a weather application user
  I want to manage weather locations and data
  So that I can track and retrieve weather information

  Background:
    Given the following test location exists:
      | city    | country | latitude | longitude |
      | London  | GB      | 51.5074  | -0.1278   |
    And the following test weather data exists:
      | temperature | feelsLike | humidity | pressure | description   | icon |
      | 15.5        | 14.2      | 72.0     | 1013.25  | Partly cloudy | 02d  |


  Scenario: Get or create existing location
    Given a location "London" with country "GB" exists in the database
    When I request to get or create location "London", "GB", 51.5074, -0.1278
    Then the location "London" with country "GB" should be returned
    And the findByCity repository method should be called with "London"

  Scenario: Create new location when it doesn't exist
    Given no location exists at latitude 48.8566 and longitude 2.3522
    And no location with city "Paris" exists
    When I request to get or create location "Paris", "FR", 48.8566, 2.3522
    Then a new location should be created and saved
    And the save repository method should be called

  Scenario: Fetch and save current weather successfully
    Given a location "London" exists
    And the OpenWeatherMap API returns current weather data with temperature 15.5°C
    When I fetch and save current weather for location "London"
    Then the weather data with temperature 15.5°C should be returned
    And the weather location should be "London"
    And the getCurrentWeather API should be called with coordinates
    And the weather data should be saved to the repository

  Scenario: Fetch and save forecast successfully
    Given a location "London" exists
    And the OpenWeatherMap API returns forecast data
    When I fetch and save forecast for location "London"
    Then the forecast list should not be empty
    And the forecast location should be "London"
    And the getForecast API should be called with coordinates
    And all forecasts should be saved to the repository

  Scenario: Get historical weather data for date range
    Given a location with id 1 exists
    And weather data exists from 7 days ago to today
    When I request historical data for location 1 from 7 days ago to today
    Then the weather data list should not be empty
    And the temperature should be 15.5°C

  Scenario: Get latest weather for a location
    Given a location with id 1 exists
    And recent weather data exists for location 1
    When I request the latest weather for location 1
    Then the latest weather data should be present
    And the temperature should be 15.5°C

  Scenario: Get upcoming forecast for a location
    Given a location with id 1 exists
    And forecast data exists for upcoming dates
    When I request the upcoming forecast for location 1
    Then the forecast list should not be empty
    And the forecast location should be "London"

  Scenario: Get all locations
    Given multiple locations exist in the database
    When I request all locations
    Then the locations list should not be empty
    And the first location should be "London"

  Scenario: Delete location and related data
    Given a location with id 1 exists
    And weather data exists for location 1
    And forecast data exists for location 1
    When I delete the location with id 1
    Then all weather data for location 1 should be deleted
    And all forecast data for location 1 should be deleted
    And the location should be deleted from the repository

  Scenario: Get cities by country
    Given locations exist for country "GB"
    When I request cities for country "GB"
    Then the locations list should not be empty
    And all locations should be from country "GB"
    And locations should be sorted by city name

  Scenario: Get all distinct countries
    Given locations exist for multiple countries: GB, FR, JP, US
    When I request all distinct countries
    Then the countries list should contain "GB", "FR", "JP", "US"
    And the list should have 4 countries