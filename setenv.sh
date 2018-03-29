secretFolder="secret"

echo "create $secretFolder folder"
mkdir $secretFolder

github="123qwe"
admin="admin"

echo "create secret files"

echo $github > $secretFolder/github
echo $admin > $secretFolder/adminpw
