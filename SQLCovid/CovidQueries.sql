Select *
From CovidDeaths
Order by 3,4

--Select *
--From CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2


-- NUMBERS BY CONTINENT

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, Round((Cast(total_deaths as float) / Cast(total_cases as float))*100, 5) as DeathPercentage
From CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, Round((Cast(total_cases as float) / Cast(population as float))*100, 5) as InfectionPercentage
From CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) as HighestInfectionCount, Round((Cast(Max(total_cases) as float) / Cast(population as float))*100, 5) as InfectionPercentage
From CovidDeaths
Group by location, population
Order by InfectionPercentage DESC

-- Showing Countries with Highest Death Count per Population
Select location, Max(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc



-- NUMBERS BY CONTINENT

-- Shows likelihood of dying if you contract Covid
Select location, Max(Round((Cast(total_deaths as float) / Cast(total_cases as float))*100, 5)) as DeathPercentage
From CovidDeaths
Where continent is null
Group by location
Order by DeathPercentage desc

-- Shows what percentage of population got Covid
Select location, Max(Round((Cast(total_cases as float) / Cast(population as float))*100, 5)) as InfectionPercentage
From CovidDeaths
Where continent is null
Group by location
Order by InfectionPercentage desc

-- Looking at Continents with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) as HighestInfectionCount, Round((Cast(Max(total_cases) as float) / Cast(population as float))*100, 5) as InfectionPercentage
From CovidDeaths
Where continent is null
Group by location, population
Order by InfectionPercentage DESC

-- Showing Continents with the highest death count per population
Select location, Max(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

-- Death percentage per day
Select date, Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, 
(Cast(Sum(new_deaths) as float) / Cast(Sum(new_cases) as float))*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Death percentage TOTAL
Select Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, 
(Cast(Sum(new_deaths) as float) / Cast(Sum(new_cases) as float))*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Order by 1,2

-- Total Population vs Vaccinations Rolling
Select Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
Sum(Vac.new_vaccinations) Over (Partition by Death.location Order by Death.location, Death.date) as RollingPeopleVaccinated
From CovidDeaths Death
Join CovidVaccinations Vac
	On Death.location = Vac.location and Death.date = Vac.date
Where Death.continent is not null
Order by 2,3

-- Population vs Vaccination Rolling using CTE
With PopsvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as(
Select Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
Sum(Vac.new_vaccinations) Over (Partition by Death.location Order by Death.location, Death.date) as RollingPeopleVaccinated
From CovidDeaths Death
Join CovidVaccinations Vac
	On Death.location = Vac.location and Death.date = Vac.date
Where Death.continent is not null
)
Select *, (RollingPeopleVaccinated / Population)*100 as RollingPercentage
From PopsvsVac

-- Population vs Vaccination Rolling using CTE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
NewVaccinations int,
RollingPeopleVaccinated int
)

Insert into #PercentPopulationVaccinated
Select Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
Sum(Vac.new_vaccinations) Over (Partition by Death.location Order by Death.location, Death.date) as RollingPeopleVaccinated
From CovidDeaths Death
Join CovidVaccinations Vac
	On Death.location = Vac.location and Death.date = Vac.date
Where Death.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated / Population)*100 as RollingPercentage
From #PercentPopulationVaccinated


-- CREATING VIEW to store date for later visualizations

Create View PercentPopulationVaccinated as
Select Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
Sum(Vac.new_vaccinations) Over (Partition by Death.location Order by Death.location, Death.date) as RollingPeopleVaccinated
From CovidDeaths Death
Join CovidVaccinations Vac
	On Death.location = Vac.location and Death.date = Vac.date
Where Death.continent is not null

Select *
From PercentPopulationVaccinated