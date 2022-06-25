/*
Cleaning Data in SQL Queries
*/

-- Standardize Data Format
	-- SELECT CONVERT(DATE, SaleDate) as SaleDate
	-- FROM PortfolioProject.dbo.NashvilleHousing


SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted DATE;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CAST(SaleDate as Date)

	--Checking
SELECT SaleDate, SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

-- Populate Propety Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]



-- Breaking Out PropertyAddress Into individual Columns (Property_Address, Property_City)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD Property_Address VARCHAR(255)
	,Property_City VARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
	,Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Breaking Out OwnerAddress Into individual Columns (Owner_Address, Owner_City, Owner_State)


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD Owner_Address VARCHAR(255),
	Owner_City VARCHAR(255),
	Owner_State VARCHAR(255);
	
UPDATE PortfolioProject..NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-- Change Y and N to Yes and No in "Sold as Vacent" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant 
	END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant 
	END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant

-- Remove Duplicates Row

SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) as row_num
FROM PortfolioProject..NashvilleHousing

ALTER DATABASE PortfolioProject
SET COMPATIBILITY_LEVEL = 100

--USE CTEs
WITH RowNumber AS
(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) as row_num
FROM PortfolioProject..NashvilleHousing
)

	-- DELETE Duplicate
DELETE
FROM RowNumber
WHERE row_num > 1

	-- Check is there still have duplicate row
WITH RowNumber AS
(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) as row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumber
WHERE row_num > 1

-- Remove Unused Column

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
--RENAME SaleDateConverted to SaleDate instead
