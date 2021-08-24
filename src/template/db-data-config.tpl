<dataConfig>
    <dataSource name="ds-db" driver="com.mysql.jdbc.Driver" url="jdbc:mysql://localhost:3306/{{.DB_CMS_DB}}" user="{{.DB_User}}"
                password="{{.DB_Password}}" useSSL="false" batchSize="1"/>
    <dataSource name="ds-file" type="BinFileDataSource"/>
    <document>
        {{.Schema}}
    </document>
</dataConfig>
