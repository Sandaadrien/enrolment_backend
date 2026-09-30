export class RecentActivityDto {
  applicantName = '';
  idReference = '';
  time = '';
  status: 'Synced' | 'Local Only' = 'Local Only';
}
