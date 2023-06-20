/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing

--------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

--------------------------------------------------

-- Populate Property Address Data

Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From NashvilleHousing A
Join NashvilleHousing B
	On A.ParcelID = B.ParcelID
	And A.UniqueID <> B.UniqueID
Where A.PropertyAddress is null

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From NashvilleHousing A
Join NashvilleHousing B
	On A.ParcelID = B.ParcelID
	And A.UniqueID <> B.UniqueID
Where A.PropertyAddress is null

--------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Property Address
Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))) as City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertyAddressOnly Nvarchar(255)

Update NashvilleHousing
Set PropertyAddressOnly = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PropertyAddressCityOnly Nvarchar(255)

Update NashvilleHousing
Set PropertyAddressCityOnly = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)))

-- Owner Address
Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerAddressOnly Nvarchar(255)

Update NashvilleHousing
Set OwnerAddressOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerAddressCityOnly Nvarchar(255)

Update NashvilleHousing
Set OwnerAddressCityOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerAddressStateOnly Nvarchar(255)

Update NashvilleHousing
Set OwnerAddressStateOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant) as SoldAsVacantCount
From NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacantCount

Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	End

--------------------------------------------------

-- Remove Duplicates (Not best practice, however just to demonstrate knowledge)

With RowNumCTE as (
Select *,
	ROW_NUMBER() Over (
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by UniqueID
					 ) row_num
From NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1



With RowNumCTE as (
Select *,
	ROW_NUMBER() Over (
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by UniqueID
					 ) row_num
From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--------------------------------------------------

-- Remove Columns (Not best practice, however just to demonstrate knowledge)

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress