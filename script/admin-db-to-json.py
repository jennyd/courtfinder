import psycopg2
import json
from django.core.serializers.json import DjangoJSONEncoder
from optparse import OptionParser
from boto.s3.connection import S3Connection
from boto.s3.key import Key


class Data:

    # these descriptions are found in the admin app's locale files, not in the database
    parking_types = {"parking_onsite_free": "Free on site parking is available at this venue.",
                     "parking_onsite_paid": "Paid on site parking is available at this venue.",
                     "parking_onsite_none": "On site parking is not available at this venue.",
                     "parking_offsite_free": "Free off site parking is available within 500m of this venue.",
                     "parking_offsite_paid": "Paid off site parking is available within 500m of this venue.",
                     "parking_offsite_none": "Off site parking is not available within 500m of this venue.",
                     "parking_blue_badge_available": "Blue badge parking is available on site.",
                     "parking_blue_badge_limited": "Limited blue badge parking is available on site (please contact the venue for details).",
                     "parking_blue_badge_none": "Blue badge parking is not available at this venue."}


    def __init__(self, host, user, password, database, output_dir, access, secret, bucket):
        self.conn = psycopg2.connect("dbname='%s' user='%s' host='%s' password='%s'" % (
            database,
            user,
            host,
            password)
        )
        if output_dir is None and access is not None and secret is not None:
            conn = S3Connection(access, secret)
            self.bucket = conn.get_bucket(bucket)
        else:
            self.output_dir = output_dir

    def courts(self):
        all_courts = []
        cur = self.conn.cursor()
        cur.execute("SELECT id, name, display, court_number, slug, latitude, longitude, image_file, alert, parking_onsite, parking_offsite, parking_blue_badge, directions, cci_code, created_at, updated_at FROM courts")
        rows = cur.fetchall()
        for row in rows:
            admin_id, name, display, court_number, slug, lat, lon, image_file, alert, parking_onsite, parking_offsite, parking_blue_badge, directions, cci_code, created_at, updated_at = row
            if name == None or slug == None:
                print "- %s\n\tslug: %s, lat: %s, lon: %s" % (name, slug, lat, lon)
                continue
            aols = self.areas_of_law_for_court(slug)
            addresses = self.addresses_for_court(slug)
            court_types = self.court_types_for_court(slug)
            contacts = self.contacts_for_court(slug)
            emails = self.emails_for_court(slug)
            postcodes = self.postcodes_for_court(slug)
            facilities = self.facilities_for_court(slug)
            opening_times = self.opening_times_for_court(slug)
            parking = {}
            if parking_onsite is not None and parking_onsite != '':
                parking["onsite"] =  Data.parking_types[parking_onsite]
            if parking_offsite is not None and parking_offsite != '':
                parking["offsite"] =  Data.parking_types[parking_offsite]
            if parking_blue_badge is not None and parking_blue_badge != '':
                parking["blue_badge"] =  Data.parking_types[parking_blue_badge]
            court_object = {
                "admin_id": admin_id,
                "name": name,
                "display": display,
                "court_number": court_number,
                "slug": slug,
                "areas_of_law": aols,
                "addresses": addresses,
                "court_types": court_types,
                "contacts": contacts,
                "emails": emails,
                "facilities": facilities,
                "postcodes": postcodes,
            }
            if lat is not None:
                court_object['lat'] = str(lat)
            if lon is not None:
                court_object['lon'] = str(lon)
            if image_file is not None:
                court_object['image_file'] = image_file
            if opening_times is not None:
                court_object['opening_times'] = opening_times
            if alert not in (None, ""):
                court_object['alert'] = alert
            if len(parking) > 0:
                court_object['parking'] = parking
            if directions not in (None, ""):
                court_object['directions'] = directions
            if cci_code not in (None, ""):
                court_object['cci_code'] = cci_code
            if created_at not in (None, ""):
                court_object['created_at'] = created_at
            if updated_at not in (None, ""):
                court_object['updated_at'] = updated_at
            all_courts.append(court_object)
            print "+ %s" % name
        self.write_to_json( 'courts', all_courts )

    def contacts_for_court(self, slug):
        # contacts for court
        cur = self.conn.cursor()
        sql = """SELECT c.slug, ct.name as contact_type, co.telephone, co.sort
                   FROM courts as c,
                        contact_types ct,
                        contacts co
                  WHERE co.court_id = c.id
                    AND co.contact_type_id = ct.id
                    AND c.slug = '%s'""" % slug
        cur.execute(sql)
        contacts = [{
            "name": r[1],
            "number": r[2],
            "sort": r[3]
        } for r in cur.fetchall()]
        return contacts

    def emails_for_court(self, slug):
        cur = self.conn.cursor()
        sql = """SELECT e.address, ct.name
                   FROM courts as c,
                        contact_types ct,
                        emails e
                  WHERE e.court_id = c.id
                    AND e.contact_type_id = ct.id
                    AND c.slug = '%s'""" % slug
        cur.execute(sql)
        emails = [{ "description": r[1], "address": r[0] } for r in cur.fetchall()]
        return emails

    def facilities_for_court(self, slug):
        cur = self.conn.cursor()
        sql = """SELECT c.slug, cf.description, f.name, f.image, f.image_description
                   FROM courts as c,
                        facilities f,
                        court_facilities cf
                  WHERE cf.court_id = c.id
                    AND cf.facility_id = f.id
                    AND c.slug = '%s'""" % slug
        cur.execute(sql)
        facilities = [{
            "description": r[1],
            "name": r[2],
            "image": r[3],
            "image_description": r[4]
        } for r in cur.fetchall()]
        return facilities

    def opening_times_for_court(self, slug):
        cur = self.conn.cursor()
        sql = """SELECT ot.name, ott.name
                   FROM opening_times as ot, courts as c, opening_types as ott
                  WHERE ot.court_id = c.id
                    AND ott.id = ot.opening_type_id
                    AND c.slug = '%s'""" % slug
        cur.execute(sql)
        opening_times = [ r[1]+': '+r[0] for r in cur.fetchall()]
        return opening_times

    def court_types_for_court(self, slug):
        # court types for court
        cur = self.conn.cursor()
        sql = """SELECT ct.name as court_type
                   FROM courts as c,
                        court_types ct,
                        court_types_courts ctc
                  WHERE ctc.court_id = c.id
                    AND ctc.court_type_id = ct.id
                    AND c.slug = '%s'""" % slug
        cur.execute(sql)
        court_types =  [c[0] for c in cur.fetchall()]
        return court_types

    def areas_of_law_for_court(self, slug):
        # areas of law for court
        cur = self.conn.cursor()
        sql = """SELECT a.name, r.single_point_of_entry
                   FROM courts as c, areas_of_law as a, remits as r
                  WHERE r.court_id = c.id
                    AND r.area_of_law_id = a.id
                    AND c.slug = '%s'""" % slug
        cur.execute(sql)
        aol_list = [(a[0], a[1]) for a in cur.fetchall()]
        aols = []
        for aol_name, spoe in aol_list:
            cur = self.conn.cursor()
            sql = """SELECT la.name
                       FROM remits as r,
                            jurisdictions as j,
                            areas_of_law as aol,
                            courts as c,
                            local_authorities as la
                      WHERE r.court_id = c.id
                        AND r.area_of_law_id = aol.id
                        AND j.remit_id = r.id
                        AND j.local_authority_id = la.id
                        AND c.slug = '%s'
                        AND aol.name = '%s'
                      ORDER BY la.name""" % (slug, aol_name)
            cur.execute(sql)
            local_authorities = [la[0] for la in cur.fetchall()]

            entry = {
                "name": aol_name,
                "local_authorities": local_authorities
            }

            if spoe:
                entry['single_point_of_entry'] = spoe

            aols.append(entry)
        return aols

    def postcodes_for_court(self, slug):
        cur = self.conn.cursor()
        sql = """SELECT pc.postcode
                   FROM postcode_courts pc,
                        courts c
                  WHERE pc.court_id = c.id
                    AND c.slug = '%s'""" % slug
        cur.execute(sql)
        postcodes = [p[0] for p in cur.fetchall()]
        return postcodes

    def addresses_for_court(self, slug):
        # addresses for court
        cur = self.conn.cursor()
        sql = """SELECT t.name as town,
                        cnt.name as county,
                        at.name as address_type,
                        a.address_line_1,
                        a.address_line_2,
                        a.address_line_3,
                        a.address_line_4,
                        a.postcode
                   FROM courts as c,
                        address_types as at,
                        addresses as a,
                        towns as t,
                        counties as cnt
                  WHERE a.court_id = c.id
                    AND a.address_type_id = at.id
                    AND a.town_id = t.id
                    AND cnt.id = t.county_id
                    AND c.slug = '%s'""" % slug
        cur.execute(sql)
        addresses = [{
            "type": row[2],
            "address" : "\n".join([row[3], row[4], row[5], row[6]]),
            "postcode": row[7],
            "town": row[0],
            "county": row[1],
        } for row in cur.fetchall()]
        return addresses

    def write_to_json(self, filename, data):
        js = json.dumps(data, indent=4, separators=(',', ': '), cls=DjangoJSONEncoder)
        if hasattr(self, 'output_dir') and not hasattr(self, 'bucket'):
            with open('%s/%s.json' % (self.output_dir, filename), 'w') as f:
                f.write(js)
        else:
            self.s3_upload('%s.json' % filename, js)

    def s3_upload(self, filename, data):
        k = Key(self.bucket)
        k.key = "%s" % filename
        k.set_contents_from_string(data)
        print "Upload to S3:", k.key

def main():
    parser = OptionParser()
    parser.add_option('-x', '--host', dest='host', default=None,
                      help='Set Postgres Hostname')
    parser.add_option('-u', '--user', dest='user', default=None,
                      help='Set Postgres Username')
    parser.add_option('-p', '--password', dest='password', default=None,
                      help='Set Postgres Password')
    parser.add_option('-d', '--db', dest='database', default=None,
                      help='Set Postgres database name')
    parser.add_option('-o', '--output', dest='output', default=None,
                      help='Output directory path')
    parser.add_option('-a', '--access', dest='access', default=None,
                      help='AWS Access key')
    parser.add_option('-s', '--secret', dest='secret', default=None,
                      help='AWS Secret key')
    parser.add_option('-b', '--bucket', dest='bucket', default=None,
                      help='AWS Bucket name')
    (options, args) = parser.parse_args()
    obj = Data(options.host, options.user, options.password, options.database, options.output,
               options.access, options.secret, options.bucket)
    obj.courts()

if __name__ == '__main__':
    main()
