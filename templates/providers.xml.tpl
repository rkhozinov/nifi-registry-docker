<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<providers>

    {{ if (.Env.NIFI_REGISTRY_FLOW_PROVIDER | strings.Contains "git") }}
    <flowPersistenceProvider>
        <class>org.apache.nifi.registry.provider.flow.git.GitFlowPersistenceProvider</class>
        <property name="Flow Storage Directory">{{ getenv "NIFI_REGISTRY_FLOW_STORAGE_DIR" "./flow_storage" }}</property>
        <property name="Remote To Push">{{ .Env.NIFI_REGISTRY_GIT_REMOTE }}</property>
        <property name="Remote Access User">{{ .Env.NIFI_REGISTRY_GIT_USER }}</property>
        <property name="Remote Access Password">{{ .Env.NIFI_REGISTRY_GIT_PASSWORD }}</property>
    </flowPersistenceProvider>
    {{ else }}
    <flowPersistenceProvider>
        <class>org.apache.nifi.registry.provider.flow.FileSystemFlowPersistenceProvider</class>
        <property name="Flow Storage Directory">{{ getenv "NIFI_REGISTRY_FLOW_STORAGE_DIR" "./flow_storage" }}</property>
    </flowPersistenceProvider>
    {{ end }}

    <!--
    <eventHookProvider>
        <class>org.apache.nifi.registry.provider.hook.ScriptEventHookProvider</class>
        <property name="Script Path"></property>
        <property name="Working Directory"></property>
    </eventHookProvider>
    -->

    <!-- This will log all events to a separate file specified by the EVENT_APPENDER in logback.xml -->
    <!--
    <eventHookProvider>
        <class>org.apache.nifi.registry.provider.hook.LoggingEventHookProvider</class>
    </eventHookProvider>
    -->

</providers>
