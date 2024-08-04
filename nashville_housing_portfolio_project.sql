/*

Clean data from the Nashville Housing excel file

*/

SELECT TOP(1000) *
FROM PortfolioProject.dbo.NashvilleHousing;


------------  Standardize date format for the SaleDate column  ------------

SELECT SaleDate, CAST(SaleDate AS DATE) Date
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate DATE; -- Change column datatype from DATETIME to DATE


------------  Fix property address data where the value is NULL  ------------

-- Count how many NULL values there are in the PropertyAdress column
SELECT COUNT(*) AS PropertyAdress_null_count
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;

-- Join the table with itself to see if the the PropertyAddress is stored in another row with the same ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Update the PropertyAdress columns to they're correct values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL; 


------------  Break out property address into Address and City  ------------

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;

-- Look at the splitted PropertyAddress column into Address and City
SELECT PropertyAddress, 
	TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)) AS Address,
	TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))) AS City
FROM PortfolioProject.dbo.NashvilleHousing;

-- Create columns to stored the Address and City values
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress VARCHAR(255), PropertySplitCity VARCHAR(255);

-- Stores the Address and City values in the new columns
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = TRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)),
	PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)));


------------  Break out the owner's address into address, city and state  ------------

-- Look at the owner's address
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

-- Split the address, city and state using the owner's address
SELECT TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)) AS OwnerAddress,
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)) AS OwnerCity,
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)) AS OwnerState
FROM PortfolioProject.dbo.NashvilleHousing;

-- Create column to store the owner's address, city and state
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255),
	OwnerSplitCity VARCHAR(255),
	OwnerSplitState VARCHAR(255);

-- Store the state of each property in the new column
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)),
	OwnerSplitCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)),
	OwnerSplitAddress = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3));


------------  Change the values from the SoldAsVacant column that say 'Y' and 'N' to 'Yes' and 'NO'  ------------

-- See how many different values there are in the SoldAsVacant column
SELECT SoldAsVacant, COUNT(*)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant;

-- Fix the values from the SoldAsVacant column
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant LIKE 'N' THEN 'NO'
		WHEN SoldASVacant LIKE 'Y' THEN 'YES'
		ELSE SoldAsVacant
	END;


------------  Remove duplicated rows  ------------

-- Count duplicated rows
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference 
		ORDER BY UniqueID) AS DuplicatedRowCount
FROM PortfolioProject.dbo.NashvilleHousing;

-- Delete duplicated rows
WITH DuplicatedRowCountCTE AS (
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference 
			ORDER BY UniqueID) AS DuplicatedRowCount
	FROM PortfolioProject.dbo.NashvilleHousing
) 
DELETE FROM DuplicatedRowCountCTE
WHERE DuplicatedRowCount > 1;


------------  Delete unused columns  ------------

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;


