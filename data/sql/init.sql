# Unfortunately MySQL Workbench doesn't support spatial indexes so I'm creating them here instead

# MySQL 8 Requires SRID on geometry columns for spatial indexes to work
/*!80000 ALTER TABLE t2_survey MODIFY COLUMN coords POINT NOT NULL SRID 0 */;
/*!80000 ALTER TABLE taxon_presence_alpha_hull_subdiv MODIFY COLUMN geometry GEOMETRY NOT NULL SRID 0 */;
/*!80000 ALTER TABLE taxon_range_subdiv MODIFY COLUMN geometry MULTIPOLYGON NOT NULL SRID 0 */;
/*!80000 ALTER TABLE grid_cell MODIFY COLUMN geometry POLYGON NOT NULL SRID 0 */;
/*!80000 ALTER TABLE region_subdiv MODIFY COLUMN geometry MULTIPOLYGON NOT NULL SRID 0 */;

CREATE SPATIAL INDEX coords ON t2_survey (coords);
CREATE SPATIAL INDEX geometry ON taxon_presence_alpha_hull_subdiv (geometry);
CREATE SPATIAL INDEX geometry ON taxon_range_subdiv (geometry);
CREATE SPATIAL INDEX geometry ON grid_cell (geometry);
CREATE SPATIAL INDEX geometry ON region_subdiv (geometry);

INSERT INTO experimental_design_type (id, description) VALUES
(1, "Standardised site"),
(2, "Standardised grid"),
(3, "Unstandardised grid");

INSERT INTO response_variable_type (id, description) VALUES
(1, "Average count"),
(2, "Maximum count"),
(3, "Reporting rate");

INSERT INTO unit (id, description) VALUES
(1, "Sample: Occupancy (# presences/# absences)"),
(2, "Sample: abundance (counts)"),
(3, "Sample: density (counts/fixed areas)"),
(4, "Index"),
(5, "Proxy: recorded calls"),
(6, "Proxy: nests"),
(7, "Proxy: breeding pairs"),
(8, "Proxy: count of pre-fledging chicks"),
(9, "Sample: count of seen individuals after playback"),
(10, "Proxy: nests with eggs"),
(11, "Proxy: burrow estimate based on transect density");

INSERT INTO taxon_status (id, description) VALUES
(1, 'Least Concern'),
(2, 'Near Threatened'),
(3, 'Vulnerable'),
(4, 'Endangered'),
(5, 'Critically Endangered'),
(6, 'Critically Endangered (possibly extinct)'),
(7, 'Extinct');

INSERT INTO search_type (description) VALUES
('2ha 20 minute search'),
('500m Area search'),
('5km Area search'),
('Shorebird count area survey'),
('Breeding territory monitoring'),
('Incidental search'),
('Fixed route search'),
('Bird list'),
('Waterhole counts'),
('Aerial survey'),
('Roost counts'),
('Collected specimen'),
('VBA Bird transect'),
('VBA Breeding bird census'),
('VBA Helmeted Honeyeater survey'),
('VBA Listening'),
('VBA Mist net'),
('VBA Owl census'),
('VBA Plains-wanderer survey'),
('VBA Playback'),
('VBA Point spot count'),
('VBA Spotlighting'),
('VBA Spotlighting by area'),
('VBA Spotlighting on foot'),
('VBA Swift Parrot Survey'),
('VBA Targeted search'),
('VBA Timed bird census'),
('VBA Trap (unspecified)'),
('Unknown'),
('VBA Wetland count'),
('Estimation of annual breeding pairs by aerial photography and ground surveys'),
('Colony count'),
('Counting of birds seen after playback'),
('Slow walk (2-4km/h), listening to bird calls'),
('Annual flock count as flock flies to roosting area'),
('Direct observation at nest'),
('Search through feeding habitat patch'),
('4ha 20 minute search'),
('10 minute point count'),
('2ha non-20 minute search'),
('Automated call recordering'),
('LaTrobe Mallee call playback/spot counts');

INSERT INTO `range` (id, description) VALUES
  (1, "Core range"),
  (2, "Suspect"),
  (3, "Vagrant"),
  (4, "Historical"),
  (5, "Irruptive"),
  (6, "Introduced");
