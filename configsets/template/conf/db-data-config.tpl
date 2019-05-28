<dataConfig>
    <dataSource name="ds-db" driver="com.mysql.jdbc.Driver" url="jdbc:mysql://localhost:3306/{{DB_CMS_DB}}" user="{{DB_USER}}"
                password="{{DB_PASSWORD}}" useSSL="false" batchSize="1"/>
    <dataSource name="ds-file" type="BinFileDataSource"/>
    <document>
        {{DB_DATA_CONFIG_SCHEMA}}
    </document>
</dataConfig>
