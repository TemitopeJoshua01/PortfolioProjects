
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinationss
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

Select Location, date, total_cases, total_deaths, CAST(total_deaths as Float) / CAST(total_cases as Float) * 100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

Select Location, date, population, total_cases,  CAST(total_cases as Float) / CAST(population as Float) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select Location, population, MAX(total_cases) AS HighestInfectionCount,  MAX(CAST(total_cases as Float) / CAST(population as Float)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POULATION

Select Location, MAX(CAST(Total_deaths AS INT)) as TotaldeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotaldeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(CAST(Total_deaths AS INT)) as TotaldeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotaldeathCount desc

-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT

Select continent, MAX(CAST(Total_deaths AS INT)) as TotaldeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotaldeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, Sum(new_deaths) as total_deaths, CAST(SUM(new_deaths) AS FLOAT) / CAST(SUM(new_cases)AS FLOAT)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2

-- COVID VACCINATION

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinationss vac
	on dea.location = vac.location
	and dea.date = vac.date

-- LOOKING AT TOTAL POPULATION VS VACCINATION

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinationss vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

-- USING PARTITION BY

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinationss vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinationss vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, Cast(RollingPeopleVaccinated as float) / CAST (Population as float)*100
From PopvsVac

-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinationss vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *, Cast(RollingPeopleVaccinated as float) / CAST (Population as float)*100
From #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinationss vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated