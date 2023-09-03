Select *
From PortfolioProj..CovidDeaths
Where continent is not null
order by 3,4


--Select *
--From PortfolioProj..CovidVaccinations
--order by 3,4



-- Select Data that we are goin to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProj..CovidDeaths
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProj..CovidDeaths
Where location = 'United States'
and continent is not null
order by 1, 2



-- Looking at the Total Case vs Population
-- Shows what percentage of population that got Covid

Select location, date, population, total_cases,  (total_cases/population)* 100 as PercentageInfected
From PortfolioProj..CovidDeaths
Where location = 'United States'
and continent is not null
order by 1, 2



-- Looking at Countries with Highest Infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))* 100 as PercentagePopulationInfected
From PortfolioProj..CovidDeaths
Group by location, population
order by PercentagePopulationInfected desc




-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProj..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc



-- Let's Break Things Down by Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProj..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc




-- Showing continents with the highest death count percentage

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProj..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc




-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProj..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2




-- Joining the tables together(CovideDeaths & CovidVaccinations)

Select *
From PortfolioProj..CovidDeaths dea
Join PortfolioProj..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date




-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProj..CovidDeaths dea
Join PortfolioProj..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3




-- Use CTE (Total Vaccinated Population Percentage)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProj..CovidDeaths dea
Join PortfolioProj..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as TotalVacPopPerc
From PopvsVac