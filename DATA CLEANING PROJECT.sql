-- CLEANING DATA IN SQL QUERIES

Select *
From PortfolioProject.dbo.NashvilleHousing

-- STANDARDIZE DATE FORMAT

Select SaleDate, Convert(Date,saledate)
From PortfolioProject.dbo.NashvilleHousing

-- POPULATE PROPERTY ADDRESS DATA: MEANING TO COMBINE ROLLS WITH SAME PROPERTY ADDRESS AS ONE

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) USING SUBSTRINGS

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress)-1) as Address
, SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) USING PARSENAME

Select OwnerAddress
From PortfolioProject..NashvilleHousing

SELECT
PARSENAME (REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME (REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME (REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing

--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 1 Then 'YES' 
		When SoldAsVacant = 0 THEN 'NO' 
		Else CAST(SoldAsVacant AS varchar)
		END
From PortfolioProject.dbo.NashvilleHousing

-- OR 


Select SoldAsVacant
, Case When SoldAsVacant = 1 Then 'YES' 
		ELSE 'NO'
		END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 1 Then 'YES' 
		When SoldAsVacant = 0 THEN 'NO' 
		Else CAST(SoldAsVacant AS varchar)
		END

-- REMOVE DUPLICATES


SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				 SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

SELECT *
From PortfolioProject.dbo.NashvilleHousing

-------------------- THIS CODE DELETES THE DUPLICATE ROWS

WITH RowNumCTE As(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				 SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

DELETE
From RowNumCTE
Where row_num > 1

-- AFTER EXECUTING, 104 ROWS WERE AFFECTED, NOW THE NEXT CODE CHECKS THE NEW TABLE
-------------------------

WITH RowNumCTE As(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				 SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- DELETE UNUSED COLUMNS

SELECT *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
