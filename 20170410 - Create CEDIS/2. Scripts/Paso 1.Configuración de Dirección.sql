DECLARE

BEGIN

    HR_LOCATION_API.CREATE_LOCATION
        (
             p_validate                       => FALSE,
            ,p_effective_date                 => SYSDATE
            ,p_language_code                  => hr_api.userenv_lang
            ,p_location_code                  => CONFIGURATION_CEDIS_PKG.GET_PARAMETER_VALUE('CREATE_LOCATION', 'P_LOCATION_CODE'),
            ,p_description                    => CONFIGURATION_CEDIS_PKG.GET_PARAMETER_VALUE('CREATE_LOCATION', 'P_DESCRIPTION'),
            ,p_timezone_code                  => 'MX'
            ,p_address_line_1                 => CONFIGURATION_CEDIS_PKG.GET_PARAMETER_VALUE('CREATE_LOCATION', 'P_DESCRIPTION'),
            ,p_address_line_2                 => 
            ,p_address_line_3                 IN  VARCHAR2  DEFAULT NULL
            ,p_bill_to_site_flag              => 'Y'
            ,p_country                        IN  VARCHAR2  DEFAULT NULL
            ,p_designated_receiver_id         IN  NUMBER    DEFAULT NULL
            ,p_in_organization_flag           IN  VARCHAR2  DEFAULT 'Y'
            ,p_inactive_date                  IN  DATE      DEFAULT NULL
            ,p_operating_unit_id              IN  NUMBER    DEFAULT NULL
            ,p_inventory_organization_id      IN  NUMBER    DEFAULT NULL
            ,p_office_site_flag               IN  VARCHAR2  DEFAULT 'Y'
            ,p_postal_code                    IN  VARCHAR2  DEFAULT NULL
            ,p_receiving_site_flag            IN  VARCHAR2  DEFAULT 'Y'
            ,p_region_1                       IN  VARCHAR2  DEFAULT NULL
            ,p_region_2                       IN  VARCHAR2  DEFAULT NULL
            ,p_region_3                       IN  VARCHAR2  DEFAULT NULL
            ,p_ship_to_location_id            IN  NUMBER    DEFAULT NULL
            ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
            ,p_style                          IN  VARCHAR2  DEFAULT NULL
            ,p_tax_name                       IN  VARCHAR2  DEFAULT NULL
            ,p_telephone_number_1             IN  VARCHAR2  DEFAULT NULL
            ,p_telephone_number_2             IN  VARCHAR2  DEFAULT NULL
            ,p_telephone_number_3             IN  VARCHAR2  DEFAULT NULL
            ,p_town_or_city                   IN  VARCHAR2  DEFAULT NULL
            ,p_loc_information13              IN  VARCHAR2  DEFAULT NULL
            ,p_loc_information14              IN  VARCHAR2  DEFAULT NULL
            ,p_loc_information15              IN  VARCHAR2  DEFAULT NULL
            ,p_loc_information16              IN  VARCHAR2  DEFAULT NULL
            ,p_loc_information17              IN  VARCHAR2  DEFAULT NULL
            ,p_loc_information18              IN  VARCHAR2  DEFAULT NULL
            ,p_loc_information19              IN  VARCHAR2  DEFAULT NULL
            ,p_loc_information20              IN  VARCHAR2  DEFAULT NULL
            ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
            ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
            ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
            ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute_category      IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute1              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute2              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute3              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute4              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute5              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute6              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute7              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute8              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute9              IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute10             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute11             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute12             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute13             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute14             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute15             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute16             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute17             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute18             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute19             IN  VARCHAR2  DEFAULT NULL
            ,p_global_attribute20             IN  VARCHAR2  DEFAULT NULL
            ,p_business_group_id              IN  NUMBER    DEFAULT NULL
            ,p_location_id                    OUT NOCOPY NUMBER
            ,p_object_version_number          OUT NOCOPY NUMBER
        )

END;