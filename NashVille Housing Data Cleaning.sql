-- Cleaning Data in SQL Queries

Select *
From [Portfolio Project]..[NashvilleHousing]

--Standarize Date Format

Select SaleDateConverted,CONVERT(Date,SaleDate)
From [Portfolio Project].dbo.[NashvilleHousing]

Update [NashvilleHousing]
SET SaleDate = CONVERT(Date,Saledate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

-- Populate Property Adress

Select *
From [Portfolio Project]..[NashvilleHousing]
-- Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..[NashvilleHousing] a
JOIN [Portfolio Project].dbo.[NashvilleHousing] b
    on a.parcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..[NashvilleHousing] a
JOIN [Portfolio Project].dbo.[NashvilleHousing] b
    on a.parcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Breaking out Address Into Individual Collums ( Address, City, State)

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing


Select
SUBSTRING (PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))as Address


From [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project]..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET PropertySplitCity =  SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',' , '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',' , '.'), 1)
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 3)

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 2)

ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 1)

Select *
From [Portfolio Project].dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacanr" Field

Select Distinct(SoldAsVacant), COunt(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project]..NashvilleHousing 

Update [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Restore Duplicates 

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num

From [Portfolio Project]..NashvilleHousing 
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused Columns

Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- Organizing the Table in a more comprehensive Manner

CREATE VIEW ComprehensiveTable AS
SELECT UniqueID, ParcelID, LandUse,SalePrice, SaleDateConverted, propertySplitAddress, PropertySplitCity, OwnerSplitAddress,OwnerSplitCity, OwnerSplitState, SoldAsVacant, OwnerName, Acreage, landValue,BuildingValue,TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath
From [Portfolio Project]..NashvilleHousing

-- Final Table Display

Select * FROM ComprehensiveTable;