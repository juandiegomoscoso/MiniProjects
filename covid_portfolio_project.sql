-- Look at the percentage of total deaths relative to total cases each day in Argentina
SELECT location, date, total_cases, total_deaths,
	CASE 
		WHEN total_cases = 0 THEN 0 -- This line prevents the division by zero error
		ELSE (CAST(total_deaths AS FLOAT) / total_cases) * 100
	END AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE 'Argentina'
ORDER BY location, date;

-- Calculate the percentage of the population that has contracted covid
SELECT location, date, total_cases, population,
	CASE 
		WHEN population = 0 THEN 0 -- This line prevents the division by zero error
		ELSE (CAST(total_cases AS FLOAT) / population) * 100
	END AS population_with_covid
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE 'Argentina'
ORDER BY location, date;

-- Look at countries with the highest infection rate relative to population
SELECT location, population, MAX(total_cases) AS highest_cases_count, 
	COALESCE(CAST(MAX(total_cases) AS FLOAT) / NULLIF(population, 0) * 100, 0) AS percentage_population_infected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent NOT LIKE '' AND location NOT LIKE '%countries'
GROUP BY location, population
ORDER BY percentage_population_infected DESC;

-- Look at countries with the highest deaths from covid count
SELECT location, population, MAX(total_deaths) AS highest_deaths_count, 
	COALESCE(CAST(MAX(total_deaths) AS FLOAT) / NULLIF(population, 0) * 100, 0) AS percentage_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent NOT LIKE '' AND location NOT LIKE '%countries'
GROUP BY location, population
ORDER BY percentage_deaths DESC;

-- look at the countries with the most deaths
SELECT location, MAX(total_deaths) AS total_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent NOT LIKE '' AND location NOT LIKE '%countries'
GROUP BY location
ORDER BY MAX(total_deaths) DESC;

-- look at the continents total_deaths
SELECT location, MAX(total_deaths) AS total_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent LIKE '' AND location NOT LIKE '%countries'
GROUP BY location
ORDER BY MAX(total_deaths) DESC;

-- Show the continents with the highest deaths from covid per population
SELECT location, population, COALESCE(CAST(MAX(total_deaths) AS FLOAT) / NULLIF(population, 0) * 100, 0) AS percentage_deaths_per_population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent LIKE '' AND location NOT LIKE '%countries'
GROUP BY location, population
ORDER BY percentage_deaths_per_population DESC;

-- Show global percentage of new deaths per new cases per day
SELECT date, SUM(new_cases) AS new_cases, SUM(new_deaths) AS new_deaths, 
	COALESCE(CAST(SUM(new_deaths) AS FLOAT) / NULLIF(SUM(new_cases), 0) *100, 0) AS new_deaths_per_new_cases
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent NOT LIKE '' AND location NOT LIKE '%countries'
GROUP BY date
ORDER BY date;

-- Show global percentage of total deaths per total cases up to 2024-07-29
SELECT MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, 
	CAST(MAX(new_deaths) AS FLOAT) / MAX(new_cases) * 100  AS deaths_per_cases
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE 'World';

-- Join the CovidDeaths table with the CovidVaccinations table to see how many new vaccinations there were per day
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS total_vaccinations,
	(CAST(SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.date) AS FLOAT) / CD.population) * 100 AS population_vaccinated
FROM PortfolioProject.dbo.CovidDeaths AS CD
JOIN PortfolioProject.dbo.CovidVaccinations AS CV
	ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent NOT LIKE '' AND CD.location NOT LIKE '%countries'
ORDER BY CD.location, CD.date;




--select DISTINCT(location)
--from PortfolioProject.dbo.CovidDeaths
--WHERE continent LIKE '' OR location LIKE '%countries'
--ORDER BY location;

--SELECT MAX(total_cases), MAX(total_deaths)
--FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE 'World';