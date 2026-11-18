# QoS

Ok! QoS in place.Script fires off a full mesh test, have metrics for those. Then, applied QoS fabric wide at 1251, with a 20 minute run time on the script.
This took quite a while to structure the qos pieces in avd to account for various chipsets and to apply the right classification at the right places
Full mesh script is working fine,
Need to figure out how to test that stuff succeeds. I’m not filling up the pipelines..
Important to note that the structured config in LEAFs.yml can also be done as custom_structured_configuration in the child/parent files (leafs, spines, etc). That works well, except when you have multiple chipsets in a single child. The only way around it was structured_config in the node groups.
This applies to the uplink qos where we want “trust dscp” as well.
Full mesh, eds devices some reach 186Gb/s, other less depending on who talked to the splunks. Need to figure out how to get more 100G involved, OUTSIDE of rack 1. Rack5?
