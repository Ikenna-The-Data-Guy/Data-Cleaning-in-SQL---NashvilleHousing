/*

Cleaning Housing Data in SQL

*/

SELECT *
FROM NashvilleHousing


--Standardize Date Format(We want to get rid of the time value in the SaleDate field)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-------------------------------------------------------------------------------------------------------------------------


--Populate Property Address Data(to see if the NULL property address values can be traced.
--I used the ParcelID as a reference field)

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress is NULL          -- There are 29 occurrences

SELECT *                               -- Here, I discovered that the ParcelID & Property Address are the same.                  
FROM NashvilleHousing
WHERE PropertyAddress is NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress       -- I did a JOIN to look at the fields side-by-side                   
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)                         
FROM NashvilleHousing a
JOIN NashvilleHousing b                                    --I make use of the ISNULL function to populate the 
	ON a.ParcelID = b.ParcelID				               --property address for the missing ones.
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b                                    
	ON a.ParcelID = b.ParcelID				               
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT PropertyAddress          -- Running a check
FROM NashvilleHousing
WHERE PropertyAddress is NULL 



----------------------------------------------------------------------------------------------------------------


-- Seperating the Address Field Into Different Columns (Address, City, & State)

SELECT PropertyAddress          
FROM NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))	

SELECT *                            -- To check on what we did. The the 2 new fields can be found at the end of the table.
FROM NashvilleHousing


SELECT OwnerAddress                 -- Working on the OwnerAddress column
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)	

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)	

SELECT *                 -- Checking our work to see the added columns of Owner details
FROM NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant Column"

SELECT DISTINCT SoldAsVacant            -- To ensure that only 4 values are in the field
FROM NashvilleHousing


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)            -- To find out how many cells of Y and N we're working on
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,                                    -- We use the CASE statement to effect the changes
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing
WHERE SoldAsVacant IN ('Y' ,'N') 


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)            -- To check whether the changes were effected
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS                                                     -- helps us to filter out the duplicates (104 rows)
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS                                                               -- to delete the duplicates.
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


WITH RowNumCTE AS                                                               -- Checking for the duplicates. All gone!
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns.

SELECT *                                   -- To view everything we have and decide which columns we want to drop.
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing        -- Forgot to include "SaleDate" column in the last ALTER TABLE statement.
DROP COLUMN SaleDate
 

SELECT *                   -- To view the table after dropping the columns "OwnerAddress",
FROM NashvilleHousing      --  "TaxDistrict", "SaleDate", and "PropertyAdress".



-----------------------------------------------------------------------------------------------------------

