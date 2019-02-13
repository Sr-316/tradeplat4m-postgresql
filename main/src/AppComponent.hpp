//
//  AppComponent.hpp
//  file-service
//
//  Created by Leonid on 8/13/18.
//  Copyright © 2018 oatpp. All rights reserved.
//

#ifndef AppComponent_hpp
#define AppComponent_hpp

#include "dto/ConfigDto.hpp"

#include "oatpp/parser/json/mapping/ObjectMapper.hpp"
#include "oatpp/core/macro/component.hpp"

#include "oatpp/core/base/CommandLineArguments.hpp"

#include <fstream>

class AppComponent {
private:
  oatpp::base::CommandLineArguments m_cmdArgs;
public:
  AppComponent(const oatpp::base::CommandLineArguments& cmdArgs)
    : m_cmdArgs(cmdArgs)
  {}
public:
  
  /**
   * This should be configured through config-server ex. Consul
   */
  OATPP_CREATE_COMPONENT(ConfigDto::ObjectWrapper, config)([this] {

    const char* configPath = CONFIG_PATH;
    auto objectMapper = oatpp::parser::json::mapping::ObjectMapper::createShared();
    
    oatpp::String configText = oatpp::base::StrBuffer::loadFromFile(configPath);
    if (configText) {

      auto profiles = objectMapper->readFromString<ConfigDto::Fields<ConfigDto::ObjectWrapper>>(configText);
      const char* profileArg = m_cmdArgs.getNamedArgumentValue("--profile", "dev");

      OATPP_LOGD("Server", "Loading configuration profile '%s'", profileArg);

      auto profile = profiles->get(profileArg, nullptr);
      if(!profile) {
        throw std::runtime_error("No configuration profile found. Server won't run.");
      }
      return profile;
      
    }
    
    OATPP_LOGE("AppComponent", "Can't load configuration file at path '%s'", configPath);
    throw std::runtime_error("[AppComponent]: Can't load configuration file");
    
  }());
  
};

#endif /* AppComponent_hpp */
