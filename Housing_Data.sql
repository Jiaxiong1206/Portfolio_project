-- Select top 1000 rows 
Select Top(1000) [UniqueID],
[ParcelID],
[LandUse],
[PropertyAddress],
[SaleDate],
[SalePrice],
[LegalReference],
[SoldAsVacant],
[OwnerName],
[OwnerAddress],
[Acreage],
[TaxDistrict],
[LandValue],
[BuildingValue],
[TotalValue],
[YearBuilt],
[Bedrooms],
[FullBath],
[Halfbath]

From [Portfolio_project]..[housing_data]



--Cleaning Data in SQL

Select *
From portfolio_project..housing_data

-- Standardise the date format

select SaleDateConverted, CONVERT(Date, SaleDate)
from [Portfolio_Project ]..housing_data

Alter table housing_data 
Add SaleDateConverted Date;

UPDATE dbo.housing_data 
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Populate Property Address data

Select *
From portfolio_project..housing_data
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..housing_data a
JOIN portfolio_project..housing_data b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..housing_data a
JOIN portfolio_project..housing_data b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]


-- Breaking out  Address into individual columns (Address, city, state)
Select PropertyAddress
From portfolio_project..housing_data

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From portfolio_project..housing_data

Alter table housing_data 
Add PropertySplitAddress Nvarchar(255);

UPDATE dbo.housing_data 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

Alter table housing_data 
Add PropertySplitCity Nvarchar(255);

UPDATE dbo.housing_data 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress));

Select *
From portfolio_project..housing_data

Select OwnerAddress
From portfolio_project..housing_data

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From portfolio_project..housing_data

Alter table housing_data 
Add OwnerAddressSplit Nvarchar(255);

UPDATE dbo.housing_data 
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

Alter table housing_data 
Add OwnerCitySplit Nvarchar(255);

UPDATE dbo.housing_data 
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

Alter table housing_data 
Add OwnerSplit Nvarchar(255);

UPDATE dbo.housing_data 
SET OwnerSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

Select *
From portfolio_project..housing_data
Where OwnerSplit is not null

-- Change Y and N to Yes and No in "sold as vacant" field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from Portfolio_Project..housing_data
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From portfolio_project..housing_data

UPDATE dbo.housing_data 
SET SoldAsVacant = Case when SoldAsVacant = 'y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 
From portfolio_project..housing_data


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by UniqueID
				 ) row_num

From portfolio_project..housing_data
--Order by ParcelID
)

Delete
From RowNumCTE
where row_num > 1

-- Delete Unused Column 

Select *
From portfolio_project..housing_data

Alter Table portfolio_project..housing_data
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table portfolio_project..housing_data
Drop Column SaleDate
