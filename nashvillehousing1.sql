--Cleaning Data in SQL queries

select *
from NashvilleHousing 


--------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Data Format

select SaleDate 
--convert(date, SaleDate) already Exists
from NashvilleHousing


alter table NashvilleHousing
add SalesDateConverted Date;

update NashvilleHousing
set SalesDateConverted = convert(date, SaleDate)

select SalesDateConverted
from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------

--Populate property Address data

select *
from NashvilleHousing
where PropertyAddress is null
--order by Parcelid

 
select a.uniqueid, a.parcelid, a.propertyaddress,b.uniqueid, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress) as Updatedpropertyaddress
from NashvilleHousing a
join NashvilleHousing b
on a.Parcelid = b.parcelid and a.uniqueid <> b.uniqueid
where a.propertyaddress is null
 


 update a
 set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
 from NashvilleHousing a
join NashvilleHousing b
on a.Parcelid = b.parcelid and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


--------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, city, state)

select PropertyAddress
from NashvilleHousing 

select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress)) as address
from NashvilleHousing

alter table NashvilleHousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set propertysplitaddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',propertyaddress)-1)

alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress))


SELECT 
    SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1) as street_address,
    LTRIM(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1)) as city,
    'TN' as state
FROM NashvilleHousing;


select 
PARSENAME(replace(owneraddress, ',','.'),3),
PARSENAME(replace(owneraddress, ',','.'),2),
PARSENAME(replace(owneraddress, ',','.'),1)
from NashvilleHousing 


alter table NashvilleHousing
add ownersplitaddress nvarchar(255);


update NashvilleHousing
set ownersplitaddress = PARSENAME(replace(owneraddress, ',','.'),3)

alter table NashvilleHousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity = PARSENAME(replace(owneraddress, ',','.'),2)

alter table NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate = PARSENAME(replace(owneraddress, ',','.'),1)

--------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to yes and No in "Sold as vacant" field

select *

from NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SoldAsVacantText AS 
    CASE 
        WHEN SoldAsVacant = 0 THEN 'No'
        WHEN SoldAsVacant = 1 THEN 'Yes'
        
    END;
	

select SoldAsVacantText, COUNT(SoldAsVacantText)
from NashvilleHousing
group by SoldAsVacantText

--------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

with rownumcte as (
select *,
row_number() over(partition by parcelid,propertyaddress, saleprice, saledate, legalreference order by uniqueid) row_num
from NashvilleHousing
)
select *
from rownumcte
where row_num > 1


--------------------------------------------------------------------------------------------------------------------------------------------

--Delete unused columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column owneraddress, propertyaddress, taxdistrict,saledate