import glob
import json

import pandas as pd
import numpy as np


def main(file_format):

    files_summary = glob.glob(file_format)
    metadata = pd.DataFrame()
    for k in files_summary:
        f = open(k)
        data = json.load(f)
        df = pd.json_normalize(data)
        df['filename'] = k
        metadata = pd.concat([metadata, df])
    metadata.index = range(0, len(metadata))

    # TODO: 74 missing, that is summary-24
    for tt in range(0, len(metadata)):
        try:
            subject_id = int(metadata['filename'][tt][8:10])
            if not (tt > -1):
                print('Not proceeding further:', subject_id)
                continue
            else:
                print('Proceeding further:', subject_id)
            blendshape_data = pd.DataFrame()
            prefix = metadata['filename'][tt][0:58]
            f = open(prefix + 'summary-' + str(subject_id) + '.json')
            summary = json.load(f)
            blendhsape_names = summary['blendShapes']
            idx = 0
            for k in metadata['samples'][tt]:
                idx = idx + 1
                try:
                    f = open(prefix + k + '.json')
                    data = json.load(f)
                    temp1 = pd.json_normalize(data)[['trackingSample.blendShapeValues', 'trackingSample.timestamp']]
                    temp = pd.DataFrame(temp1['trackingSample.blendShapeValues'][0]).transpose()
                    temp.columns = blendhsape_names
                    temp['timestamp'] = temp1['trackingSample.timestamp']
                    blendshape_data = pd.concat([blendshape_data, temp])
                except:
                    continue
                print(f"{subject_id}: {np.round((idx / len(metadata['samples'][tt])) * 100, 2)}% completed;", end='\r')
            blendshape_data.index = range(0, len(blendshape_data))
            blendshape_data['subject'] = summary['id']

            blendshape_data['hasVisualAid'] = summary['survey']['hasVisualAid']
            blendshape_data['usesVisualAid'] = summary['survey']['usesVisualAid']
            blendshape_data['needsNewVisualAid'] = summary['survey']['needsNewVisualAid']

            blendshape_data['canReadCinemaSubtitles'] = summary['survey']['canReadCinemaSubtitles']
            blendshape_data['canReadSmartphoneScreen'] = summary['survey']['canReadSmartphoneScreen']
            blendshape_data['canReadRoadSigns'] = summary['survey']['canReadRoadSigns']
            blendshape_data['wasEasy'] = summary['survey']['wasEasy']
            blendshape_data['distance'] = summary['distance']

            try:
                blendshape_data['visualAidDiopters'] = summary['survey']['visualAidDiopters']
            except:
                blendshape_data['visualAidDiopters'] = 0.0

            results = pd.DataFrame(metadata['result.characters'][tt])
            results['letter_row'] = results.index + 1
            results['label'] = np.round(
                10 * np.diff(np.append(np.array(results.logMAR), metadata['result.logMAR'][tt])))
            results['label'] = results.label.replace(-1, 'all').replace(0, 'some').replace(1, 'none')
            results['subject'] = summary['id']

            final = pd.merge_asof(
                blendshape_data,
                results[['startedAt', 'letter_row']],
                left_on='timestamp',
                right_on='startedAt',
                direction='backward',
            )

            save_str_option = ''
            suppress_squinting = False
            try:
                save_str_option = metadata['options'][tt][0]
                suppress_squinting = True
            except:
                pass
            final['suppress_squinting'] = suppress_squinting
            results['suppress_squinting'] = suppress_squinting
            final.to_csv('../temp/blendshapes_' + str(summary['id']) + '_' + save_str_option + '.csv')
            results.to_csv('../temp/results_' + str(summary['id']) + '_' + save_str_option + '.csv')
        except Exception as e:
            print(e)
            continue

if __name__ == "__main__":
    main('../data/**/**/summary-pass*.json')
