/* Cleaning Data in SQL Queries */

Select * 
From HousingData.dbo.NashvilleHousing

-- Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
From HousingData.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update HousingData.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------------------------------------------
-- Populate Property Address data
-- There is a matching parcel Id for each property address
-- So we will use this to populate the NULL values in the Property Address column
Select *
From HousingData.dbo.NashvilleHousing
where PropertyAddress is null

Select *
From HousingData.dbo.NashvilleHousing
order by ParcelID


-- Doing a self join
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-- Property Address
Select PropertyAddress
From HousingData.dbo.NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From HousingData.dbo.NashvilleHousing

ALTER TABLE HousingData.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE HousingData.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Owner Address
Select OwnerAddress
From HousingData.dbo.NashvilleHousing

-- Note: Parse names only works with periods, that is why we are using replace to have it recognize commas
-- Note: Since parsename works backwards, we are counting commas as 3 2 1 instead of 1 2 3
Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From HousingData.dbo.NashvilleHousing

ALTER TABLE HousingData.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE HousingData.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE HousingData.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update HousingData.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

------------------------------------------------------------------------------------------------------------
-- Chnge Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingData.dbo.NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldASVacant
	 END
From HousingData.dbo.NashvilleHousing

Update HousingData.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldASVacant
	 END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingData.dbo.NashvilleHousing
Group by SoldAsVacant;


--------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

-- Finding Duplicates
WITH  RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by 
			 UniqueID) row_num
From HousingData.dbo.NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress


-- Deleting Duplicates
WITH  RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by 
			 UniqueID) row_num
From HousingData.dbo.NashvilleHousing
-- order by ParcelID
)
Delete 
From RowNumCTE
Where row_num > 1

----------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From HousingData.dbo.NashvilleHousing

ALTER TABLE HousingData.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




