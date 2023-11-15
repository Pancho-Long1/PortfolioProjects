Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

Select *
From [Portfolio Project]..CovidVaccinations
where continent is not null
order by 3,4

-- Selecting Data

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dyiing if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date,Population, total_cases,(total_cases/population)*100 as PopulationWithCovid
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Countries with HIghest Infection Rate compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationWithCovid
From [Portfolio Project]..CovidDeaths
Group by Location, Population
Where continent is not null
order by PopulationWithCovid desc

-- Showing Countries with Highest Death Count per Population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Breakdown by Continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Continents with the Highest Death Count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (New_deaths as int))/SUM(New_Cases) *100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Total population vs Vaccinations

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- With CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population Numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for Later Vizualizations

-- View of Populaition Vaccinated Per Country

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- View of chances of dying per country

Create View CovidDeathRates as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null

-- View of Population with Covid Per Country

Create View PopulationWithCovid as
Select location, date,Population, total_cases,(total_cases/population)*100 as PopulationWithCovid
From [Portfolio Project]..CovidDeaths
where continent is not null

-- View of Death Count Per Continent

Create View ContinentalDeathCount as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
