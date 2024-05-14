import glob
import pandas as pd


def zscore_normalize(x):
    std = x.std()
    if std == 0:
        return x - x.mean()
    else:
        return (x - x.mean()) / x.std()


def main():
    import numpy as np
    files_preprocessed_blendhsapes = glob.glob('../temp/blendshapes*.csv')
    files_preprocessed_results = glob.glob('../temp/results*.csv')

    df = pd.DataFrame()
    for k in files_preprocessed_blendhsapes:
        t = pd.read_csv(k)
        threshold = np.median(t.jawOpen)
        t = t[t.jawOpen < threshold]
        t.loc[:, list(t.columns[1:-14])] = t.loc[:, list(t.columns[1:-14]) + ['subject']].groupby('subject').transform(
            zscore_normalize)
        df = pd.concat([df, t])
    df.index = range(0, len(df))

    results = pd.DataFrame()
    for k in files_preprocessed_results:
        results = pd.concat([results, pd.read_csv(k)])
    results.index = range(0, len(results))

    values = ['subject', 'hasVisualAid', 'usesVisualAid', 'needsNewVisualAid',
              'canReadCinemaSubtitles', 'canReadSmartphoneScreen', 'canReadRoadSigns',
              'wasEasy', 'distance', 'visualAidDiopters', 'letter_row',
              'suppress_squinting']

    df = df.drop(['Unnamed: 0', 'timestamp', 'startedAt'], axis=1)

    df = df.groupby(values, as_index=False).agg(['max', 'mean', 'min', 'std']).reset_index()

    df.columns = [''.join(col).strip() for col in df.columns.values]

    results = results[['subject', 'letter_row', 'label', 'suppress_squinting', 'logMAR', 'fontSizePt']]
    df = pd.merge(df, results, how='left', on=['subject', 'letter_row', 'suppress_squinting'])
    df.to_csv('../temp/train_data.csv', index=False)


if __name__ == "__main__":
    main()
