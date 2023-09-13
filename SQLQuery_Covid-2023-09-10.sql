Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Where continent is not null
order by 1,2

-- Total Cases vs Population

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentCases
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate vs. Population

Select location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by 4 desc

-- Countries with Highest Death Rate

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Broken down by continent


-- Continents with highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(New_Deaths as int))/SUM(New_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--Total Population vs Vacinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
order by 2,3

--CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinated/Population)*100 as RollingVaccinatedPercent
From PopvsVac

-- Temp Table


Drop Table if exists
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric,
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingVaccinated/Population)*100 as RollingVaccinatedPercent
From #PercentPopulationVaccinated 

-- Creating View to Store Data for Visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =  vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated