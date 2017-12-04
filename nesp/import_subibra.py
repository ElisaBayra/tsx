from nesp.db import get_session
import logging
import sys
import argparse
from tqdm import tqdm
import shapely.wkb
from nesp.geo import reproject_fn, to_multipolygon, subdivide_geometry
from shapely.geometry import shape
import fiona
import pyproj

log = logging.getLogger(__name__)

def main():
	logging.basicConfig(stream=sys.stdout, level=logging.INFO, format='%(asctime)-15s %(name)s %(levelname)-8s %(message)s')

	parser = argparse.ArgumentParser(description='Import sub-IBRA regions from shapefile')
	parser.add_argument('filename', type=str, help='Shapefile containing sub-IBRA regions')
	args = parser.parse_args()

	session = get_session()

	with fiona.open(args.filename, encoding = 'Windows-1252') as shp:
		reproject = reproject_fn(pyproj.Proj(shp.crs), pyproj.Proj('+init=EPSG:4326'))
		for feature in tqdm(shp):
			props = feature['properties']


			for geometry in subdivide_geometry(reproject(shape(feature['geometry']))):

				geometry = to_multipolygon(geometry)

				session.execute("""INSERT INTO region (id, name, geometry)
					VALUES (:id, :name, ST_GeomFromWKB(_BINARY :geometry_wkb))""", {
						'id': props['subIBRA_ID'],
						'name': props['Name'],
						'geometry_wkb': shapely.wkb.dumps(geometry)
					})

	session.commit()

if __name__ == '__main__':
	main()