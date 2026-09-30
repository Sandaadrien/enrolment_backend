export class RecentActivityDto {
  applicantName!: string;
  idReference!: string;
  time!: string;
  status!: 'Synced' | 'Local Only';
}

export class DashboardDto {
  enrolmentsToday!: number;
  pendingSync!: number;
  pendingSyncLabel!: string;
  recentActivity!: RecentActivityDto[];
}
