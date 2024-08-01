/*

	Data Cleaning

*/


/*   Standardize date format (converting from "datetime" datatype(DT) to "date" DT)   */

select *
from Portfolio_Projects.dbo.NashvilleHousing

alter table nashvillehousing
alter column saledate date


/*   populate property address data   */

select *
from Portfolio_Projects.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Projects.dbo.NashvilleHousing a
join Portfolio_Projects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --here instead of b.PropertyAddress we can also assign some text
from Portfolio_Projects.dbo.NashvilleHousing a				--for ex: ISNULL(a.PropertyAddress, 'No Address')
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


/*   Bereaking out address into individual columns(Address, City, State)   */

--property address

select PropertyAddress
from Portfolio_Projects.dbo.NashvilleHousing

select	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as cityaddress
from Portfolio_Projects.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress varchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity varchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select *
from Portfolio_Projects.dbo.NashvilleHousing
order by ParcelID

--Owner address

select parsename(replace(OwnerAddress, ',','.'), 3),
parsename(replace(OwnerAddress, ',','.'), 2),
parsename(replace(OwnerAddress, ',','.'), 1)
from Portfolio_Projects.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress varchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.'), 3)

alter table NashvilleHousing
add OwnerSplitCity varchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.'), 2)

alter table NashvilleHousing
add OwnerSplitState varchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'), 1)

  
/*   Changing 'Y' & 'N' to 'Yes' & 'No' in "sold as vacant" field   */


select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio_Projects.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from Portfolio_Projects.dbo.NashvilleHousing
order by SoldAsVacant


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

/*   Remove Duplicates   */

with RowNumCTE as(
select *,
	ROW_NUMBER() over(partition by parcelID,
					propertyaddress,
					saleprice,
					saledate,
					legalreference
					order by
					uniqueID
					) row_num
from Portfolio_Projects.dbo.NashvilleHousing
--order by parcelID
)
select *
--Delete
from RowNumCTE
where row_num > 1


/*  Delete unused Columns  */

select *
from Portfolio_Projects.dbo.NashvilleHousing

Alter table Portfolio_Projects.dbo.NashvilleHousing
Drop column propertyaddress, owneraddress, taxdistrict
