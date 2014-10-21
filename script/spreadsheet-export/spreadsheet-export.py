import json
import pprint
import re

import psycopg2
import xlrd

pp = pprint.PrettyPrinter(indent=4)

conn = psycopg2.connect("dbname='%s' user='%s' host='%s'" % (
    'courtfinder_production',
    'courtfinder',
    'localhost'))


council_exception_list = {
    "Rhondda Cynon Taff Borough Council":       "Rhondda Cynon Taf Council",
    "St.Helens Metropolitan Borough Council":   "St Helens Borough Council",
    "Ynys Mon County Council":                  "Isle of Anglesey Council"
}

council_map = {}
court_map = {}

def main():
    global council_map
    with open('council_map.json', 'r') as fhandle:
        council_map = json.load(fhandle)
        fhandle.close()

    book = xlrd.open_workbook('spreadsheet/DFJ areas, LAs, POE and venues.xls')

    book_dict = {}
    for sheet in book.sheets():
        book_dict[sheet.name] = process_sheet( sheet )

    # pp.pprint(book_dict)


def process_sheet( sheet ):
    sheet_dict = sheet_to_dict(sheet)
    

    return sheet_dict

def sheet_to_dict( sheet ):
    out = []
    for col in range(1, sheet.ncols):
        # if the column isn't about Courtfinder Rules
        if sheet.cell(0, col).value.lower().find('courtfinder') == -1:
            la_list = sheet.cell(1, col).value.split('\n')
            la_list = [find_la(a.strip()) for a in la_list if a.strip() != '']

            court_list = set([sheet.cell(2, col).value.split('\n')[0].strip()])
            for i in xrange(3, 10):
                court_list.update(set( [c.strip() for c in sheet.cell(i, col).value.split('\n')] ))

            row = {
                "Area": sheet.cell(0, col).value,
                "Local Authorities Covered": la_list,
                "Courts": [find_court(c) for c in court_list]
            }

            out.append(row)

    return out


def find_court( court_name ):
    cur = conn.cursor()
    cur.execute("SELECT name FROM courts WHERE name = '%s'" % court_name)
    results = [res[0] for res in cur.fetchall()]

    if len(results) == 1:
        return results [0]

    court_name = court_name.lower()

    for token in ['CC' , 'Mags', 'Family', 'Court']:
        court_name = court_name.replace(token, '')

def find_la( la_name ):
    return council_map[la_name]


def find_la_from_db( la_name ):
    cur = conn.cursor()
    cur.execute("SELECT name FROM councils WHERE name = '%s'" % la_name)
    results = [res[0] for res in cur.fetchall()]

    if len(results) == 1:
        return results[0]    

    if la_name in council_exception_list:
        return council_exception_list[la_name]

    la_name = la_name.lower()

    for token in ['royal borough of', 'royal', 'lb', 'metropolitan', 'county', 'city', ' borough', 'council', ',']:
        la_name = la_name.replace(token, '')

    la_name = la_name[0:la_name.find('&')]
    la_name = re.sub(r'\s+', ' ', la_name).strip()

    cur.execute("SELECT name FROM councils WHERE lower(name) like '%%%s%%'" % la_name)
    results = [res[0] for res in cur.fetchall()]
    if len(results) == 1:
        return results[0]
    else:
        return None

if __name__ == '__main__':
    main()