Select *
From PortfolioProjectCovid..CovidDeaths1
Order By 3, 4 

Select *
From PortfolioProjectCovid..CovidVaccinations
Order By 3, 4;

Select Location, Date, Total_cases, New_Cases, Total_Deaths, Population
From CovidDeaths
Order By 1, 2;


-- Looking at Total Cases vs Total Deaths in the US
-- Shows the likelyhood of 

Select Location, Date, Total_cases, Total_Deaths, (Total_Deaths*100/NULLIF(Total_Cases, 0)) AS 'Death_Percentage'
From CovidDeaths
Where Location like '%states%'
Order By 1, 2

-- Looking at Total Cases vs Population in US
--Shows what percentage of population got COVID

Select Location, Date, Population, Total_cases, (Total_Cases*100./Population) AS 'Percent_Population_Infected'
From CovidDeaths
Where Location like '%states%'
Order By 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
-- Caveat: is this data accurately the infection rate b/c couldn't the "total cases" also include people who got COVID multiple time?

Select Location, Population, MAX(Total_Cases) as 'Highest_Infection_Count', MAX(Total_Cases)*100./Population AS 'Percent_Population_Infected'
From CovidDeaths
Group By Location, Population
Order By 4 DESC

--- Showing the Countries with the Highest Death Count
-- Only include countires, not continents (Continents are included in Location column when Continent column is unknown)

Select Location, MAX(Total_Deaths) as 'Total_Death_Count'
From CovidDeaths
WHERE Continent is not null
Group By Location
Order By 2 DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT 
-- to do this, you have to filter the location column b/c if you just filter the continent, you'll be including continent total number and the number of every country (since every country column entry includes a continent column entry). So essentially, if the continent column is null, then the location should have the name of the continent. This also includes other entries like 'World' and 'Low-income countries'
-- showing the continents with the highest death count per population

Select location, MAX(Total_Deaths) as 'Total_Death_Count'
From CovidDeaths
WHERE Continent is null
Group By Location
Order By 2 DESC

--GLOBAL NUMBERS
--Note that in the data, it says that on 2020-01-05, there are 3 new deaths and 2 total & new cases. I don't understand how this is possible bc every death should be at least one case.

Select SUM(new_cases) Total_Cases, SUM(new_deaths) Total_Deaths, SUM(new_deaths)/SUM(NULLIF(New_Cases, 0))*100 DeathPercentage --, Total_Deaths, (Total_Deaths*100/NULLIF(Total_Cases, 0)) AS 'Death_Percentage'
From CovidDeaths
Where Location = 'World'
--Group By date
Order By 1, 2

--Looking at Total Population VS Vaccination
--Join 2 tables

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(Partition by dea.location Order By dea.date, dea.date) Rolling_People_Vac_By_Country
FROM CovidDeaths dea
Join CovidVaccines vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
Where dea.continent is not null
Order BY 2, 3

-- USE A CTE
-- Note that the Percentage_Vac could be over 100 because the same person could getting vaccinated more than once. I think. I'm not sure how the vaccinated data was collected.

With PopVsVac (Cibtutbebt, Location, Date, Population, New_Vaccinations, Rolling_People_Vac_By_Country)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(Partition by dea.location Order By dea.date, dea.date) Rolling_People_Vac_By_Country
FROM CovidDeaths dea
Join CovidVaccines vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
Where dea.continent is not null
--Order BY 2, 3
)

SELECT *, (Rolling_People_Vac_By_Country/Population)*100 Percentage_Vac
From PopVsVac

--TEMP Table for Percent of Population Vaccinated

Drop Table if exists #Percent_Population_Vac
Create Table #Percent_Population_Vac
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric, 
Rolling_People_Vac_By_Country numeric
)

Insert into #Percent_Population_Vac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(Partition by dea.location Order By dea.date, dea.date) Rolling_People_Vac_By_Country
FROM CovidDeaths dea
Join CovidVaccines vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
Where dea.continent is not null
--Order BY 2, 3

SELECT *, (Rolling_People_Vac_By_Country/Population)*100 Percentage_Vac
From #Percent_Population_Vac

--Creating View to store data for later visualization
--This is NOT a temp table. It is stored in the "Views" folder

Create View Percent_Population_Vac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(Partition by dea.location Order By dea.date, dea.date) Rolling_People_Vac_By_Country
FROM CovidDeaths dea
Join CovidVaccines vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
Where dea.continent is not null
--Order BY 2, 3

